# frozen_string_literal: true

# As a work of the United States Government, this project is in the
# public domain within the United States.
#
# Additionally, we waive copyright and related rights in the work
# worldwide through the CC0 1.0 Universal public domain dedication.

module BGS
  class DdeftWebService < BGS::Base
    def bean_name
      'DdeftWebServiceBean'
    end

    def self.service_name
      'ddeft'
    end
  end
end
