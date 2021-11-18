# frozen_string_literal: true

require_relative 'breakers_methods'

module MPI
  module V1
    class Service
      include SentryLogging
      include Common::Client::Concerns::Monitoring

      STATSD_KEY_PREFIX = 'api.mvi'

      def initialize
        @service = MasterPersonIndex::Service.new
      end

      def add_person(user_identity)
        return_val =
          begin
            with_monitoring do
              @service.add_person(convert_add_user(user_identity))
            end
          rescue Breakers::OutageException => e
            Raven.extra_context(breakers_error_message: e.message)
            log_message_to_sentry('MVI add_person connection failed.', :warn)
            @service.mvi_add_exception_response_for(MasterPersonIndex::Constants::OUTAGE_EXCEPTION, e)
          end

        if return_val.error.present?
          original_error = return_val.error
          increment_failure('add_person', original_error)
          log_message_to_sentry("MVI add_person error: #{original_error.message}", :warn)
          mvi_error_handler(user_identity, original_error)

          return_val.error = build_exception(return_val.error_code, original_error)
        end

        return_val
      end

      def find_profile(user_identity, search_type = MasterPersonIndex::Constants::CORRELATION_WITH_RELATIONSHIP_DATA)
        tag_search_type(user_identity)

        return_val =
          begin
            with_monitoring do
              @service.find_profile(convert_user(user_identity), search_type)
            end
          rescue Breakers::OutageException => e
            Raven.extra_context(breakers_error_message: e.message)
            log_message_to_sentry('MVI find_profile connection failed.', :warn)
            @service.mvi_profile_exception_response_for(MasterPersonIndex::Constants::OUTAGE_EXCEPTION, e)
          end

        if return_val.error.present?
          original_error = return_val.error
          increment_failure('find_profile', original_error)
          log_message_to_sentry("MVI find_profile error: #{original_error.message}", :warn)
          mvi_error_handler(user_identity, original_error)

          return_val.error = build_exception(return_val.error_code, original_error)
        end

        return_val
      end

      private

      def tag_search_type(user_identity)
        if user_identity.mhv_icn.present?
          Raven.tags_context(mvi_find_profile: 'icn')
        elsif user_identity.edipi.present?
          Raven.tags_context(mvi_find_profile: 'edipi')
        else
          Raven.tags_context(mvi_find_profile: 'user_attributes')
        end
      end

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

      def convert_add_user(user_identity)
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
          icn_with_aaid
          search_token
        ].each do |attr|
          attributes[attr] = user_identity.public_send(attr)
        end

        MasterPersonIndex::Models::UserToCreate.new(
          attributes
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
