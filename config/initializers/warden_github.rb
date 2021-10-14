# frozen_string_literal: true

Warden::GitHub::User.module_eval do
  def api
    Octokit::Client.new(access_token: Settings.sidekiq.github_api_key)
  end
end

Warden::GitHub::Strategy.module_eval do
  extend ActiveSupport::Concern
  included do
    def authenticate!
      if session[:sidekiq_user].present?
        success!(session[:sidekiq_user])
        redirect!(request.url)
      else
        super
      end
    end

    def finalize_flow!
      session[:sidekiq_user] = load_user if session[:sidekiq_user].present?
      super
    end
  end
end

Rails.configuration.middleware.use Warden::Manager do |config|
  config.failure_app = ->(env){ TestUserDashboard::OAuthController.action(:unauthorized).call(env) }
  config.default_strategies :github

  config.scope_defaults :tud, config: {
    client_id: Settings.tud.github_oauth_key,
    client_secret: Settings.tud.github_oauth_secret,
    scope: 'read:user,read:org',
    redirect_uri: 'test_user_dashboard/oauth'
  }

  config.intercept_401 = false
  config.serialize_from_session { |key| Warden::GitHub::Verifier.load(key) }
  config.serialize_into_session { |user| Warden::GitHub::Verifier.dump(user) }
end
