# frozen_string_literal: true

module Mobile
  module V0
    module Vaccinations
      # Service that connects to CDC's vaccinations XML table
      # https://www2.cdc.gov/vaccines/iis/iisstandards/XML.asp?rpt=vax2vg
      #
      class Service
        doc = Nokogiri::XML(URI.open('https://www2.cdc.gov/vaccines/iis/iisstandards/XML.asp?rpt=vax2vg')) do |config|
          config.strict.noblanks
        end
        manufacturer_doc = Nokogiri::XML(URI.open('https://www2a.cdc.gov/vaccines/iis/iisstandards/XML.asp?rpt=tradename')) do |config|
          config.strict.noblanks
        end

        doc.root.children.each do |node|
          cvx_code = nil
          group_name = nil
          node.children.each_slice(2) do |(name, value)|
            break if cvx_code && group_name

            case name.text.strip
            when 'CVXCode'
              cvx_code = value.text.strip
            when 'Vaccine Group Name'
              group_name = value.text.strip
            end
          end

          manufacturer = nil
          if group_name == "COVID-19"
            manufacturer_doc.root.children.each do |manufacturer_node|
              break if manufacturer

              _manufacturer = nil
              match = nil
              manufacturer_node.children.each_slice(2) do |(manufacturer_name_row, manufacturer_value_row)|
                break if match == false

                # this logic needs to move
                if _manufacturer && match
                  manufacturer = _manufacturer
                  break
                end

                if manufacturer_name_row.text.strip == "Manufacturer"
                  _manufacturer = manufacturer_value_row.text.strip
                  puts _manufacturer
                end
                if manufacturer_name_row.text.strip == "CVXCode"
                  if manufacturer_value_row.text.strip == cvx_code
                    match = true
                  else
                    match = false
                  end
                end
              end
            end
          end

          vaccine = Vaccine.find_or_create_by(cvx_code: cvx_code)
          if vaccine.group_name != group_name || vaccine.manufacturer != manufacturer
            vaccine.update(group_name: group_name, manufacturer: manufacturer)
          end
        end
      end
    end
  end
end
