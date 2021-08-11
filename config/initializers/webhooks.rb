# frozen_string_literal: true

Rails.application.reloader.to_prepare do
  require './lib/webhooks/utilities'
  events_empty= Webhooks::Utilities.supported_events.empty? rescue true # todo find the incantation to shut the linter up
  if (Rails.env.development? && events_empty)
    load './lib/webhooks/utilities.rb'
    load './app/models/webhooks/utilities.rb' #
    load './lib/webhooks/registrations.rb'
  end
end