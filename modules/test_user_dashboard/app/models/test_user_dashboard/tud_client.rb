# frozen_string_literal: true

require 'active_resource'

module TestUserDashboard
  class TudClient < ::ActiveResource::Base
    # self.site = 'http://localhost:3000/test_user_dashboard/tud_accounts/'
    self.site = 'https://staging-api.va.gov/test_user_dashboard/accounts_api/'
  end
end
