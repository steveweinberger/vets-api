# frozen_string_literal: true

require 'common/client/base'
require_relative 'service'
require_relative 'configuration'

module PagerDuty
  class IncidentsClient < PagerDuty::Service
    configuration PagerDuty::Configuration

    def get_incidents(options = {})
      query = {}.merge(options)
      perform(:get, 'incidents', query).body
    end

    def filter_incidents(resp)
      incidents = resp['incidents']
      incidents.each do |incident|
        #filter by VAOS-specific alerts
      end
    end
    
  end
end
