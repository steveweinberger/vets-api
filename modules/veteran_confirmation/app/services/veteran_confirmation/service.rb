# frozen_string_literal: true

require 'mpi/service'
require 'mpi/configuration'

module VeteranConfirmation
  class Service < MPI::Service
    configuration MPI::Configuration

    # This method is a simplified version of the one found in MPI::Service. It exists largely to avoid a
    # problematic validation will cause the MPI call to fail.
    def create_profile_message(user_identity, search_type: MPI::Constants::CORRELATION_WITH_RELATIONSHIP_DATA)
      message_user_attributes(user_identity, search_type)
    end
  end
end
