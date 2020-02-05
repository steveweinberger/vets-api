# frozen_string_literal: true

module ExtrnalApi
  class SearchController < ApplicationController
    def show
      # call `search` on a service object
      search_result = search_service.search(params['query'])
      render json: search_result
    end

    private

    def search_service
      @searcher ||= Search2::Service.new
    end
  end
end
