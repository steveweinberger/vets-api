# frozen_string_literal: true

require 'bid/awards/configuration'
require 'bid/service'
require 'common/client/base'

module BID
  module Awards
    class Service < BID::Service
      configuration BID::Awards::Configuration
      STATSD_KEY_PREFIX = 'api.bid.awards'

      def get_awards_pension
        with_monitoring do
          perform(
            :get,
            end_point,
            nil,
            request_headers
          )
        end
      end

      private

      def request_headers
        external_key = @user.common_name || @user.email
        external_key = external_key[0, 39] if external_key.length > 39

        {
          Authorization: "Bearer #{Settings.bid.awards.credentials}",
          ExternalUid: @user.icn,
          ExternalKey: external_key
        }
      end

      def end_point
        "#{Settings.bid.awards.base_url}/api/v1/awards/pension/#{@user.participant_id}"
      end
    end
  end
end
