require "rails_helper"

RSpec.describe 'ID.me login', type: :system do
  before do
    driven_by :selenium_chrome
    VCR.turn_off!
    Capybara.app_host = 'https://staging.va.gov'
    Capybara.run_server = false # don't start Rack
  end

  it 'can log in an LOA1 user' do
    visit '/'
    click_button 'Sign in'
  end
end
