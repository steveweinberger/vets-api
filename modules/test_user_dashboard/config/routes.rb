# frozen_string_literal: true

TestUserDashboard::Engine.routes.draw do
  resources :oauth, only: [:index]
  resources :tud_accounts, only: [:index, :update]
end
