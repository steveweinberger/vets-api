# frozen_string_literal: true

require 'common/client/base'

module Search2
  # This class builds a wrapper around Search.gov web results API. Creating a new instance of class
  # will and calling #results will return a ResultsResponse upon success or an exception upon failure.
  #
  # @see https://search.usa.gov/sites/7378/api_instructions
  #
  class Service < Common::Client::Base
    include Common::Client::Monitoring

    STATSD_KEY_PREFIX = 'api.search2' # what is this for?

    configuration Search::Configuration

    RESULT_LIMIT = 10

    def initialize
      # initialize something?
    end

    # GETs a list of search results from Search.gov web results API
    # @return results data
    #
    def search(query, page = 1)
      with_monitoring do
        response = perform(:get, search_path, search_params(query, page))
        # TODO - WIP need type and id key, can check in search_request_spec
        {
          data: { attributes: { body: response.body } },
          meta: { pagination: 1 }
        }
      end
    end

    private

    def search_path
      config.base_path
    end

    # Required params [affiliate, access_key, query]
    # Optional params [enable_highlighting, limit, offset, sort_by]
    #
    # @see https://search.usa.gov/sites/7378/api_instructions
    #
    def search_params(query, page)
      {
        affiliate: affiliate,
        access_key: access_key,
        query: query,
        offset: offset(page),
        limit: RESULT_LIMIT
      }
    end

    def affiliate
      Settings.search.affiliate
    end

    def access_key
      Settings.search.access_key
    end

    def offset(page)
      if page <= 1
        # We want first page of results
        0
      else
        # Max offset for search API is 999
        # If there are 20 results and the user requests page 3, there will be an empty result set
        [((page - 1) * RESULT_LIMIT), 999].min
      end
    end
  end
end