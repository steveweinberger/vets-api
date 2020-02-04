# frozen_string_literal: true

VeteranVerification::Engine.routes.draw do
  match '/v0/*path', to: 'application#cors_preflight', via: [:options]
  match '/address_validation_metadata', to: 'metadata#address_validation_metadata', via: [:get]

  namespace :v0, defaults: { format: 'json' } do
    resources :service_history, only: [:index]
    resources :disability_rating, only: [:index]
    get 'status', to: 'veteran_status#index'
  end

  namespace :docs do
    namespace :v0, defaults: { format: 'json' } do
      get 'service_history', to: 'api#history'
      get 'disability_rating', to: 'api#rating'
      get 'status', to: 'api#status'
      get 'veteran_verification', to: 'api#veteran_verification'
    end
  end
end
