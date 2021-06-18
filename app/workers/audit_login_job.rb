# frozen_string_literal: true

class AuditLoginJob
  include Sidekiq::Worker

  def perform(options={})
    AuditLoginService.new(options).call
  end
end
