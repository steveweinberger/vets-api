# frozen_string_literal: true

Rails.application.reloader.to_prepare do
  if (Rails.env.development?)
    Object.send(:remove_const, Webhooks::Utilities) rescue nil # todo shut linter up, don't let it refactor this
    libs = %w(./lib/webhooks/utilities.rb ./app/models/webhooks/utilities.rb ./lib/webhooks/registrations.rb).map do |f|
      File.expand_path f
    end
    libs.each do |l|
      $LOADED_FEATURES.delete(l)
    end
  end
  require './lib/webhooks/utilities'
  Webhooks::Notification.where('processing is not null').update_all(processing: nil)
end