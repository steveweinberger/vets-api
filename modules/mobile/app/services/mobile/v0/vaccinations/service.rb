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

        doc.root.children.each do |node|
          cvx_code = nil
          group_name = nil
          node.children.each_slice(2) do |(name, value)|
            break if cvx_code && group_name

            case name.text
            when 'CVXCode'
              cvx_code = value.text.strip
            when 'Vaccine Group Name'
              group_name = value.text.strip
            end
          end

          vaccine = Vaccine.find_or_create_by(cvx_code: cvx_code)
          vaccine.update(group_name: group_name) unless vaccine.group_name == group_name
        end
      end
    end
  end
end
