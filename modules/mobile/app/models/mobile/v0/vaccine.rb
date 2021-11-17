# frozen_string_literal: true

module Mobile
  module V0
    class Vaccine < ApplicationRecord
      validates :cvx_code, presence: true, uniqueness: true
      validates :group_name, presence: true
    end
  end
end
