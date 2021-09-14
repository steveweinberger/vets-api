# frozen_string_literal: true

module Mobile
  module V0
    class Users < ApplicationRecord
      validates :user_id, presence: true
    end
  end
end
