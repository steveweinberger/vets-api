# frozen_string_literal: true

module TestUserDashboard
  class TudAccountCheckout < ApplicationRecord
    validates :account_uuid, :checkout_time, presence: true
  end
end
