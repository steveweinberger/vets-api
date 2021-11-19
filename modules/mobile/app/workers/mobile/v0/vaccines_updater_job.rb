# frozen_string_literal: true

module Mobile
  module V0
    class VaccinesUpdaterJob
      include Sidekiq::Worker

      GROUP_NAME_URL = 'https://www2.cdc.gov/vaccines/iis/iisstandards/XML.asp?rpt=vax2vg'
      MANUFACTURER_URL = 'https://www2a.cdc.gov/vaccines/iis/iisstandards/XML.asp?rpt=tradename'

      class VaccinesUpdaterError < StandardError; end

      def perform
        logger.info('BEGIN --- Updating vaccine records from CDC')
        created = 0
        updated = 0
        pre_existing = 0

        group_name_xml.root.children.each do |node|
          cvx_code = find_value(node, 'CVXCode')
          group_name = find_value(node, 'Vaccine Group Name')
          manufacturer = group_name == 'COVID-19' ? find_manufacturer(cvx_code) : nil

          vaccine = Mobile::V0::Vaccine.find_by(cvx_code: cvx_code)
          if vaccine
            if vaccine.group_name != group_name || vaccine.manufacturer != manufacturer
              vaccine.update(group_name: group_name, manufacturer: manufacturer)
              updated += 1
            else
              pre_existing += 1
            end
          else
            Mobile::V0::Vaccine.create!(cvx_code: cvx_code, group_name: group_name, manufacturer: manufacturer)
            created += 1
          end
        end

        if created + updated + pre_existing == 0
          raise VaccinesUpdaterError.new "Property name #{property_name} not found"
        end

        logger.info("Created #{created} new vaccine records")
        logger.info("Updated #{updated} vaccine records")
        logger.info("Skipped #{pre_existing} vaccine records that have not changed")
        logger.info('END --- Updating vaccine records from CDC')
      end

      private

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
        raise VaccinesUpdaterError.new "Property name #{property_name} not found"
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
