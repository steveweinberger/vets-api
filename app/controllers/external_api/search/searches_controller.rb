# frozen_string_literal: true

module ExternalApi::Search
  class SearchesController < ApplicationController
    def show
      search_result = search_service.search(params['query'])
      render json: search_result
    end

    private

    def search_service
      @searcher ||= Search2::Service.new
    end
  end
end
