# frozen_string_literal: true

require 'search/service'

module V0
  class SearchController < ApplicationController
    include ActionView::Helpers::SanitizeHelper

    skip_before_action :authenticate

    # Returns a page of search results from the Search.gov API, based on the passed query and page.
    #
    # Pagination schema follows precedent from other controllers that return pagination.
    # For example, the app/controllers/v0/prescriptions_controller.rb.
    #
    def index
      response = Search::Service.new(query, page).results

      render json: response, serializer: SearchSerializer, meta: { pagination: response.pagination }
    end

    def track_search_result_click
      # Send a click event to the search.gov admin dashboard for comprehensive analytics
      # The full search.gov API request should look like https://api.gsa.gov/technology/searchgov/v2/clicks?url={URL}&query={QUERY}&affiliate=logstash&position={POSITION}&module_code={MODULE_CODE}&access_key={ACCESS_KEY}=&client_ip={CLIENT_IP}&user_agent={USER_AGENT}
      # Example scenario - A user on www.va.gov/search?query=health (query=search) clicked search result linking to https://benefits.va.gov (url=https://benefits.va.gov)

      # url, query, user_agent, and client_ip will all be collected here.
      # The search service will appent the other params.

      url = params[:url]
      query = params[:query]
      user_agent = params[:user_agent]
      client_ip = nil # todo - how to get "client_ip?"? Is this okay w/VSP security? (PII concerns?)

      Search::Service.new(nil, nil).track_click(url, query, user_agent, client_ip)

      # We probably don't need to do anything with the response
      # other than return a correct status code.
    end

    private

    def search_params
      params.permit(:query, :page)
    end

    # Returns a sanitized, permitted version of the passed query params.
    #
    # @return [String]
    # @see https://api.rubyonrails.org/v4.2/classes/ActionView/Helpers/SanitizeHelper.html#method-i-sanitize
    #
    def query
      sanitize search_params['query']
    end

    # This is the page (number) of results the FE is requesting to have returned.
    #
    # Returns a sanitized, permitted version of the passed page params. If 'page'
    # is not supplied, it returns nil.
    #
    # @return [String]
    # @return [NilClass]
    # @see https://api.rubyonrails.org/v4.2/classes/ActionView/Helpers/SanitizeHelper.html#method-i-sanitize
    #
    def page
      sanitize search_params['page']
    end
  end
end
