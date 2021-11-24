# frozen_string_literal: true

require 'mpi/service'
require 'mpi/configuration'

module VeteranConfirmation
  class Service < MPI::Service
    configuration MPI::Configuration
  end
end
