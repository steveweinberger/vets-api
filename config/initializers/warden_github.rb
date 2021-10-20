# frozen_string_literal: true

module WardenGitHubUserExtensions
  def api
    binding.pry
    # Confirm this works with Sidekiq
    if token
      super
    else
      Octokit::Client.new(access_token: Settings.sidekiq.github_api_key)
    end
  end
end

module WardenGithubStrategyExtensions
  def authenticate!
    if scope == :sidekiq && session[:sidekiq_user].present?
      success!(session[:sidekiq_user])
      redirect!(request.url)
    else
      super
    end
  end

  def finalize_flow!
    session[:sidekiq_user] = load_user if scope == :sidekiq
    super
  end
end

Warden::GitHub::Strategy.module_eval do
  prepend WardenGithubStrategyExtensions
end

Warden::GitHub::User.module_eval do
  prepend WardenGitHubUserExtensions
end

Rails.configuration.middleware.use Warden::Manager do |config|
  config.default_strategies :github

  config.scope_defaults :tud, config: {
    client_id: Settings.test_user_dashboard.github_oauth.client_id,
    client_secret: Settings.test_user_dashboard.github_oauth.client_secret,
    scope: 'read:user,read:org',
    redirect_uri: 'test_user_dashboard/oauth'
  }

  config.intercept_401 = false
  config.serialize_from_session { |key| Warden::GitHub::Verifier.load(key) }
  config.serialize_into_session { |user| Warden::GitHub::Verifier.dump(user) }
end
