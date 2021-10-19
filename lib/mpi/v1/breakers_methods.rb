module MPI
  module V1
    module BreakersMethods
      def breakers_service
        return @service if defined?(@service)

        @service = create_new_breakers_service(breakers_matcher, breakers_exception_handler)
      end

      def breakers_matcher
        base_uri = URI.parse(base_path)
        proc do |request_env|
          request_env.url.host == base_uri.host && request_env.url.port == base_uri.port &&
            request_env.url.path =~ /^#{base_uri.path}/
        end
      end

      def breakers_exception_handler
        proc do |exception|
          if exception.is_a?(Common::Exceptions::BackendServiceException)
            (500..599).cover?(exception.response_values[:status])
          elsif exception.is_a?(Common::Client::Errors::HTTPError)
            (500..599).cover?(exception.status)
          elsif exception.is_a?(Faraday::ClientError)
            # we're not yet using Faraday > 1.0, but when we do, 500 errors will be Faraday::ServerError
            (500..599).cover?(exception.response[:status])
          else
            false
          end
        end
      end

      def create_new_breakers_service(matcher, exception_handler)
        Breakers::Service.new(
          name: service_name,
          request_matcher: matcher,
          error_threshold: breakers_error_threshold,
          exception_handler: exception_handler
        )
      end

      # The percentage of errors over which an outage will be reported as part of breakers gem
      #
      # @return [Integer] corresponding to percentage
      def breakers_error_threshold
        50
      end

      def allow_missing_certs?
        !Rails.env.production?
      end
    end
  end
end

MasterPersonIndex::Configuration.class_eval { include MPI::V1::BreakersMethods }
