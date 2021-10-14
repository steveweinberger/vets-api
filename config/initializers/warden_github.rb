# frozen_string_literal: true

Warden::GitHub::User.module_eval do
  def api
    Octokit::Client.new(access_token: Settings.sidekiq.github_api_key)
  end
end

Warden::GitHub::Strategy.module_eval do
  # def authenticate!
  #   if session[:user].present?
  #     success!(session[:user])
  #     redirect!(request.url)
  #   elsif in_flow?
  #     continue_flow!
  #   else
  #     begin_flow!
  #   end
  # end

  def finalize_flow!
    session[:user] = load_user
    redirect!(custom_session['return_to'])
    teardown_flow
    throw(:warden)
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
