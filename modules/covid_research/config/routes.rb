# frozen_string_literal: true

CovidResearch::Engine.routes.draw do
  namespace :volunteer, defaults: { format: :json } do
    post 'create', to: 'submissions#create'
    # ToDo uncomment prior to deployment
    # post 'update', to: 'submissions#update'
  end
end
