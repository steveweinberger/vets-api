# frozen_string_literal: true

module VeteranConfirmation
  class Service < MPI::Service
    configuration MPI::Configuration

    # This method is a simplified version of the one found in MPI::Service. It exists largely to avoid a
    # problematic validation that will cause the MPI call to fail.
    def create_profile_message(user_identity, search_type: MPI::Constants::CORRELATION_WITH_RELATIONSHIP_DATA)
      message_user_attributes(user_identity, search_type)
    end

    def measure_info(_user_attributes, &block)
      Rails.logger.measure_info('Performed MVI Query', &block)
    end
  end
end
