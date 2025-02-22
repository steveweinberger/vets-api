# frozen_string_literal: true

require_dependency 'mobile/application_controller'

module Mobile
  module V0
    class MaintenanceWindowsController < ApplicationController
      skip_before_action :authenticate

      # deers? vbms? vacols? corpDB?
      SERVICE_GRAPH = Mobile::V0::ServiceGraph.new(
        %i[bgs evss],
        %i[mpi evss],
        %i[bgs caseflow],
        %i[arcgis facility_locator],
        %i[caseflow appeals],
        %i[emis military_service_history],
        %i[evss claims],
        %i[evss direct_deposit_benefits],
        %i[evss disability_rating],
        %i[evss letters_and_documents],
        %i[idme auth_idme],
        %i[mhv secure_messaging],
        %i[vaos appointments],
        %i[vet360 user_profile_update]
      )

      def index
        render json: Mobile::V0::MaintenanceWindowSerializer.new(maintenance_windows)
      end

      private

      def maintenance_windows
        upstream_maintenance_windows = ::MaintenanceWindow.end_after(Time.zone.now)
        SERVICE_GRAPH.affected_services(upstream_maintenance_windows).values
      end
    end
  end
end
