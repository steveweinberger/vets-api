# frozen_string_literal: true

TestUserDashboard::Engine.routes.draw do
  get '/oauth/is_authorized', to: 'oauth#is_authorized'
  resources :oauth, only: [:index]
  resources :tud_accounts, only: [:index, :update]
end
