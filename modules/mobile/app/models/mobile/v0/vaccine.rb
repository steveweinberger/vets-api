# frozen_string_literal: true

module Mobile
  module V0
    # Stores vaccine data from the CDC for use in Immunization records
    # @example create a new instance
    #   Mobile::V0::Vaccine.create(cvx_code: 1, group_name: 'FLU', manufacturer: 'Moderna')
    #
    class Vaccine < ApplicationRecord
      validates :cvx_code, presence: true, uniqueness: true
      validates :group_name, presence: true

      # Adds incoming name to group name unless it's already included
      # does not save record
      # @param name [String] the group name that is being added
      # @return [String] the group name
      def add_group_name(name)
        if group_name
          self.group_name += ", #{name}" unless group_name.split(',').map(&:strip).include?(name)
        else
          self.group_name = name
        end
        group_name
      end
    end
  end
end
