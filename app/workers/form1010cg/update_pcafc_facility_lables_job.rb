# frozen_string_literal: true

require 'pcafc/facilities'

module Form1010cg
  class UpdatePCAFCFacilityLablesJob
    include Sidekiq::Worker

    def perform; end

    private

    def facilities
      PCAFC::Facilities.all
    end

    def facilities_by_state_hash
      @facilities_map ||= facilities.each_with_object({}) do |res, facility|
        state = facility.address['physical']['state']
        res[state] = [] unless res[state]
        res[state].push(
          code: facility.code.split('_')[1],
          label: facility.name
        )
      end
    end

    def file_contents
      JSON.pretty_generate(facilities_by_state_hash)
    end
  end
end
