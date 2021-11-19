# frozen_string_literal: true

module Mobile
  module V0
    class Vaccine < ApplicationRecord
      validates :cvx_code, presence: true, uniqueness: true
      validates :group_name, presence: true

      def add_group_name(name)
        if group_name
          unless group_name.split(',').map(&:strip).include?(name)
            self.group_name += ", #{name}"
          end
        else
          self.group_name = name
        end
      end
    end
  end
end
