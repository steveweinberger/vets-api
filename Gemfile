# frozen_string_literal: true

source 'https://rubygems.org'

ruby '~> 2.7.4'

# Modules
path 'modules' do
  gem 'appeals_api'
  gem 'apps_api'
  gem 'check_in'
  gem 'claims_api'
  gem 'covid_research'
  gem 'covid_vaccine'
  gem 'facilities_api'
  gem 'health_quest'
  gem 'identity'
  gem 'meb_api'
  gem 'mobile'
  gem 'openid_auth'
  gem 'test_user_dashboard'
  gem 'va_forms'
  gem 'vaos'
  gem 'vba_documents'
  gem 'veteran'
  gem 'veteran_confirmation'
  gem 'veteran_verification'
end

gem 'rails', '~> 6.1'

gem 'aasm'
gem 'active_model_serializers', git: 'https://github.com/department-of-veterans-affairs/active_model_serializers', branch: 'master'
gem 'activerecord-import'
gem 'activerecord-postgis-adapter'
gem 'addressable'
gem 'aws-sdk-kms'
gem 'aws-sdk-s3', '~> 1'
gem 'aws-sdk-sns', '~> 1'
gem 'betamocks', git: 'https://github.com/department-of-veterans-affairs/betamocks', branch: 'master'
gem 'bgs_ext', git: 'https://github.com/department-of-veterans-affairs/bgs-ext.git', require: 'bgs'
gem 'blueprinter'
gem 'bootsnap', require: false
gem 'breakers'
gem 'carrierwave'
gem 'carrierwave-aws'
gem 'clam_scan'
gem 'combine_pdf'
gem 'config'
gem 'connect_vbms', git: 'https://github.com/department-of-veterans-affairs/connect_vbms.git', branch: 'master', require: 'vbms'
gem 'date_validator'
gem 'dry-struct'
gem 'dry-types'
gem 'ethon', '>=0.13.0'
gem 'faraday'
gem 'faraday_middleware'
gem 'fastimage'
gem 'fast_jsonapi'
gem 'fhir_client'
gem 'flipper'
gem 'flipper-active_record'
gem 'flipper-active_support_cache_store'
gem 'flipper-ui', '0.22.0' # Flipper#552 (CSP) in 0.22.1 is causing our styles not to load
gem 'foreman'
gem 'google-api-client'
gem 'google-apis-core'
gem 'google-apis-generator'
gem 'googleauth'
gem 'google-cloud-bigquery'
gem 'govdelivery-tms', '2.8.4', require: 'govdelivery/tms/mail/delivery_method'
gem 'gyoku'
gem 'holidays'
gem 'httpclient'
gem 'ice_nine'
gem 'iso_country_codes'
gem 'json'
gem 'jsonapi-parser'
gem 'json-schema'
gem 'json_schemer'
gem 'jwt'
gem 'kms_encrypted'
gem 'levenshtein-ffi'
gem 'liquid'
gem 'lockbox'
gem 'mail'
gem 'memoist'
gem 'mimemagic'
gem 'mini_magick'
gem 'net-sftp'
gem 'nokogiri'
gem 'notifications-ruby-client'
gem 'octokit'
gem 'oj' # Amazon Linux `json` gem causes conflicts, but `multi_json` will prefer `oj` if installed
gem 'okcomputer'
gem 'olive_branch'
gem 'operating_hours'
gem 'ox'
gem 'paper_trail'
gem 'parallel'
gem 'pdf-forms'
gem 'pdf-reader'
gem 'pg'
gem 'pghero'
gem 'pg_query'
gem 'pg_search'
gem 'prawn'
gem 'prawn-table'
gem 'puma'
gem 'puma-plugin-statsd'
gem 'pundit'
gem 'rack'
gem 'rack-attack'
gem 'rack-cors', require: 'rack/cors'
gem 'rails_semantic_logger'
gem 'rails-session_cookie'
gem 'redis'
gem 'redis-namespace'
gem 'request_store'
gem 'restforce'
gem 'rgeo-geojson'
gem 'rswag-ui'
gem 'ruby-saml'
gem 'rubyzip'
gem 'sass-rails' # Needed for PgHero dashboard
gem 'savon'
gem 'sentry-raven'
gem 'shrine'
gem 'sidekiq-scheduler'
gem 'slack-notify'
gem 'staccato'
gem 'statsd-instrument'
gem 'strong_migrations'
gem 'swagger-blocks'
gem 'typhoeus'
gem 'utf8-cleaner'
gem 'vets_json_schema', git: 'https://github.com/department-of-veterans-affairs/vets-json-schema', branch: 'master'
gem 'virtus'
gem 'warden-github'
gem 'will_paginate'
gem 'with_advisory_lock'

group :development do
  gem 'guard-rubocop'
  gem 'seedbank'
  gem 'spring', platforms: :ruby # Spring speeds up development by keeping your application running in the background
  gem 'spring-commands-rspec'

  # Include the IANA Time Zone Database on Windows, where Windows doesn't ship with a timezone database.
  # POSIX systems should have this already, so we're not going to bring it in on other platforms
  gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'debase'
  gem 'ruby-debug-ide', git: 'https://github.com/corgibytes/ruby-debug-ide', branch: 'feature-add-fixed-port-range'
  gem 'web-console', platforms: :ruby
end

group :test do
  gem 'apivore', git: 'https://github.com/department-of-veterans-affairs/apivore', branch: 'master'
  gem 'fakeredis'
  gem 'pact', require: false
  gem 'pact-mock_service', require: false
  gem 'pdf-inspector'
  gem 'rspec_junit_formatter'
  gem 'rspec-retry'
  gem 'rubocop-junit-formatter'
  gem 'simplecov', require: false
  gem 'super_diff'
  gem 'vcr'
  gem 'webrick'
end

group :development, :test do
  gem 'awesome_print' # Pretty print your Ruby objects in full color and with proper indentation
  gem 'brakeman'
  gem 'bundler-audit'
  gem 'byebug', platforms: :ruby # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'danger'
  gem 'database_cleaner'
  gem 'factory_bot_rails'
  gem 'faker'
  # CAUTION: faraday_curl may not provide all headers used in the actual faraday request. Be cautious if using this to
  # assist with debugging production issues (https://github.com/department-of-veterans-affairs/vets.gov-team/pull/6262)
  gem 'faraday_adapter_socks'
  gem 'faraday_curl'
  gem 'fuubar'
  gem 'guard-rspec'
  gem 'parallel_tests'
  gem 'pry-byebug'
  gem 'rack-test', require: 'rack/test'
  gem 'rack-vcr'
  gem 'rainbow' # Used to colorize output for rake tasks
  gem 'rspec-instrumentation-matcher'
  gem 'rspec-its'
  gem 'rspec-rails'
  gem 'rswag-specs'
  gem 'rubocop', require: false
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
  gem 'rubocop-thread_safety'
  gem 'sidekiq'
  gem 'timecop'
  gem 'webmock'
  gem 'yard'
end

# sidekiq enterprise requires a license key to download. In many cases, basic sidekiq is enough for local development
if (Bundler::Settings.new(Bundler.app_config_path)['enterprise.contribsys.com'].nil? ||
    Bundler::Settings.new(Bundler.app_config_path)['enterprise.contribsys.com']&.empty?) &&
   ENV.fetch('BUNDLE_ENTERPRISE__CONTRIBSYS__COM', '').empty? && ENV.keys.grep(/DEPENDABOT/).empty?
  Bundler.ui.warn 'No credentials found to install Sidekiq Enterprise. This is fine for local development but you may not check in this Gemfile.lock with any Sidekiq gems removed. The README file in this directory contains more information.'
else
  source 'https://enterprise.contribsys.com/' do
    gem 'sidekiq-ent'
    gem 'sidekiq-pro'
  end
end
