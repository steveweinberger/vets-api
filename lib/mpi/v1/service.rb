# frozen_string_literal: true

module MPI
  module V1
    class Service
      include SentryLogging

      def initialize
        @service = MasterPersonIndex::Service.new

        instance = MasterPersonIndex::Configuration.instance

        instance.base_path = Settings.mvi.url
        instance.ssl_cert_path = Settings.mvi.client_cert_path
        instance.ssl_key_path = Settings.mvi.client_key_path
        instance.open_timeout = Settings.mvi.open_timeout
        instance.read_timeout = Settings.mvi.timeout
        instance.processing_code = Settings.mvi.processing_code
        instance.vba_orchestration = Settings.mvi.vba_orchestration
        instance.edipi_search = Settings.mvi.edipi_search

        handlers = instance.connection.builder.handlers
        unless handlers.frozen?
          if Settings.mvi.pii_logging
            handlers.insert(-2,
                            Faraday::RackBuilder::Handler.new(Common::Client::Middleware::Logging,
                                                              'MVIRequest'))
          end
          handlers.insert(-2, Faraday::RackBuilder::Handler.new(Betamocks::Middleware)) if Settings.mvi.mock
        end
      end

      def find_profile(user_identity, search_type = MasterPersonIndex::Constants::CORRELATION_WITH_RELATIONSHIP_DATA)
        if user_identity.mhv_icn.present?
          Raven.tags_context(mvi_find_profile: 'icn')
        elsif user_identity.edipi.present?
          Raven.tags_context(mvi_find_profile: 'edipi')
        else
          Raven.tags_context(mvi_find_profile: 'user_attributes')
        end

        return_val = @service.find_profile(convert_user(user_identity), search_type)

        if return_val.error.present?
          original_error = return_val.error
          log_message_to_sentry("MVI find_profile error: #{original_error.message}", :warn)
          mvi_error_handler(user_identity, original_error)

          return_val.error = build_exception(return_val.error_code, original_error)
        end

        return_val
      end

      private

      def mvi_error_handler(user_identity, error, source = '', request = '')
        case error
        when MasterPersonIndex::Errors::DuplicateRecords
          log_exception_to_sentry(error, nil, nil, 'warn')
        when MasterPersonIndex::Errors::RecordNotFound
          Rails.logger.info('MVI Record Not Found')
        when MasterPersonIndex::Errors::InvalidRequestError
          # NOTE: ICN based lookups do not return RecordNotFound. They return InvalidRequestError
          if user_identity.mhv_icn.present?
            log_exception_to_sentry(error, {}, { message: 'Possible RecordNotFound', source: source })
          else
            log_exception_to_sentry(error, { request: request }, { message: 'MVI Invalid Request', source: source })
          end
        when MasterPersonIndex::Errors::FailedRequestError
          log_exception_to_sentry(error)
        end
      end

      def build_exception(key, error)
        Common::Exceptions::BackendServiceException.new(
          key,
          { source: self.class },
          nil,
          error.try(:body)
        )
      end

      def convert_user(user_identity)
        attributes = {}

        %w[
          first_name
          middle_name
          last_name
          birth_date
          ssn
          gender
          mhv_icn
          edipi
        ].each do |attr|
          attributes[attr] = user_identity.public_send(attr)
        end

        MasterPersonIndex::Models::User.new(
          attributes
        )
      end
    end
  end
end
