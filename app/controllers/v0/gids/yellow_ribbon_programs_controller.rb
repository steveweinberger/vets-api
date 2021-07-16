# frozen_string_literal: true

module V0
  module GIDS
    class YellowRibbonProgramsController < GIDSController
      def autocomplete
        render json: service.get_yellow_ribbon_autocomplete_suggestions_v0(scrubbed_params)
      end

      def index
        render json: service.get_yellow_ribbon_programs_v0(scrubbed_params)
      end
    end
  end
end
