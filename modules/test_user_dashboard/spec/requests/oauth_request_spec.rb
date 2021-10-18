# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TestUserDashboard::OAuthController, type: :request do
  describe '#index' do
    before do
      # from https://github.com/department-of-veterans-affairs/va.gov-workstreams/blob/master/spec/requests/workstreams_spec.rb
      # use RSpec mocks to avoid pinging live APIs during tests
      allow_any_instance_of(described_class).to receive(:authenticated?).and_return(true)
      allow_any_instance_of(described_class).to receive(:authorized?).and_return(true)
    end

    let(:url) do
      Settings.vsp_environment == 'staging' ? 'https://tud.vfs.va.gov/signin' : 'http://localhost:8000/signin'
    end

    it 'redirects to the signin url' do
      get('/test_user_dashboard/oauth')

      expect(response).to have_http_status(:redirect)
      expect(response.headers['Location']).to eq(url)
    end
  end

  describe '#authenticated_and_authorized?' do
    context 'authorized user' do
      before do
        # use RSpec mocks to avoid pinging live APIs during tests
        allow_any_instance_of(described_class).to receive(:authorized?).and_return(true)
      end

      it 'renders a successful response' do
        get('/test_user_dashboard/oauth/is_authorized')

        expect(response).to have_http_status(:ok)
      end
    end
  end
end
