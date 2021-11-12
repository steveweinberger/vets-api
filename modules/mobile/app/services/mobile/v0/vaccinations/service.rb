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

        matches = {
          current: {},
          new: {}
        }

        doc.root.children.each do |node|
          cvx_code = nil
          group_name = nil
          node.children.each_slice(2) do |(name, value)|
            case name.text
            when "CVX for Vaccine Group"
              cvx_code = value.text.strip
            when "Vaccine Group Name"
              group_name = value.text.strip
            end
          end
          if Mobile::CDC_CVX_CODE_MAP.keys.include?(cvx_code.to_i)
            matches[:current][cvx_code.to_i] = group_name
          else
            matches[:new][cvx_code.to_i] = group_name
          end
        end
        existing = matches[:current].sort.to_h
        incoming = matches[:new].sort.to_h

        puts "EXISTING"
        pp existing
        puts "INCOMING"
        pp incoming

        puts "UNIQUES"
        pp (existing.values + incoming.values).uniq.sort
      end
    end
  end
end