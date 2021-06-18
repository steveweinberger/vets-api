# frozen_string_literal: true

class LoginAudit < ApplicationRecord
  IDENTITY_PROVIDERS = %w[idme mhv dslogon login_gov]

  validates :idp, inclusion: {in: IDENTITY_PROVIDERS }
  validates :request_id, :idp, presence: true

  serialize :response
end
