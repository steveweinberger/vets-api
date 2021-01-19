# frozen_string_literal: true

module CypressViewportUpdater
  class GithubApp
    data = YAML.safe_load(File.open('config/settings.local.yml'))
    credentials = data['github_cypress_viewport_updater_bot_credentials']
    PRIVATE_KEY = OpenSSL::PKey::RSA.new(credentials['private_key'].gsub('\n', "\n"))
    APP_IDENTIFIER = credentials['app_id']

    def initialize
      @client = make_client
    end

    private

    def make_client
      payload = {
        iat: Time.now.to_i,
        exp: Time.now.to_i + (10 * 60),
        iss: APP_IDENTIFIER
      }
      jwt = JWT.encode(payload, PRIVATE_KEY, 'RS256')
      Octokit::Client.new(bearer_token: jwt)
    end
  end
end
