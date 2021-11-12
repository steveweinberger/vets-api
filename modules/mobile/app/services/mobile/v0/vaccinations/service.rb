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
          ary = node.children.to_a
          index = ary.find_index {|c| c.name == "Name" && c.text == "CVX for Vaccine Group" }
          cvx_code = ary[index + 1].text.strip
          group_name_index = ary.find_index {|c| c.name == "Name" && c.text == "Vaccine Group Name" }
          group_name = ary[group_name_index + 1].text.strip
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