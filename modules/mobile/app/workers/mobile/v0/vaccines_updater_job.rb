# frozen_string_literal: true

module Mobile
  module V0
    # This job is run daily and pulls data from the CDC to create vaccine records
    class VaccinesUpdaterJob
      include Sidekiq::Worker

      GROUP_NAME_URL = 'https://www2.cdc.gov/vaccines/iis/iisstandards/XML.asp?rpt=vax2vg'
      MANUFACTURER_URL = 'https://www2a.cdc.gov/vaccines/iis/iisstandards/XML.asp?rpt=tradename'

      class VaccinesUpdaterError < StandardError; end

      # fetches group name and manufacturer data from the CDC and stores them in the vaccines table
      def perform
        logger.info('BEGIN --- Updating vaccine records from CDC')
        results = { created: 0, updated: 0, persisted: 0 }

        group_name_xml.root.children.each do |node|
          result = process_vaccine(node)
          results[result] += 1
        end

        if (results[:created] + results[:updated] + results[:persisted]).zero?
          raise VaccinesUpdaterError, 'No records processed'
        end

        results.each_pair { |k, v| logger.info("#{k.capitalize} vaccine records: #{v}") }
        logger.info('END --- Updating vaccine records from CDC')
      end

      private

      def process_vaccine(node)
        cvx_code = find_value(node, 'CVXCode')
        group_name = find_value(node, 'Vaccine Group Name')
        manufacturer = group_name == 'COVID-19' ? find_manufacturer(cvx_code) : nil

        vaccine = Mobile::V0::Vaccine.find_by(cvx_code: cvx_code)
        if vaccine
          vaccine.add_group_name(group_name)
          # at this time, we only store manufacturers for covid-19 vaccines
          # and no covid-19 vaccines have multiple manufacturers
          vaccine.manufacturer = manufacturer
          if vaccine.changed?
            vaccine.save!
            :updated
          else
            :persisted
          end
        else
          Mobile::V0::Vaccine.create!(cvx_code: cvx_code, group_name: group_name, manufacturer: manufacturer)
          :created
        end
      end

      def group_name_xml
        @group_name_xml ||= Nokogiri::XML(URI.parse(GROUP_NAME_URL).open) do |config|
          config.strict.noblanks
        end
      end

      def manufacturer_xml
        @manufacturer_xml ||= Nokogiri::XML(URI.parse(MANUFACTURER_URL).open) do |config|
          config.strict.noblanks
        end
      end

      def find_value(node, property_name)
        node.children.each_slice(2) do |(name, value)|
          return value.text.strip if name.text.strip == property_name
        end
        raise VaccinesUpdaterError, "Property name #{property_name} not found"
      end

      def find_manufacturer(cvx_code)
        manufacturer_xml.root.children.each do |node|
          current_node_cvx = find_value(node, 'CVXCode')
          next unless current_node_cvx == cvx_code

          return find_value(node, 'Manufacturer')
        end
        nil
      end
    end
  end
end
