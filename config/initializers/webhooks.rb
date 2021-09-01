# frozen_string_literal: true

Rails.application.reloader.to_prepare do
  if Rails.env.development?
    begin
      Object.send(:remove_const, Webhooks::Utilities)
    rescue
      nil
    end
    libs = %w[./lib/webhooks/utilities.rb ./app/models/webhooks/utilities.rb ./lib/webhooks/registrations.rb].map do |f|
      File.expand_path f
    end
    libs.each do |l|
      $LOADED_FEATURES.delete(l)
    end
  end
  require './lib/webhooks/utilities'
end
