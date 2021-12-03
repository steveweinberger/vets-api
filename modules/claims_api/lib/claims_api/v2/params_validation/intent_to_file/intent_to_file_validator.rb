# frozen_string_literal: true

module ClaimsApi
  module V2
    module ParamsValidation
      module IntentToFile
        class IntentToFileValidator < ActiveModel::Validator
          def validate(record)
            validate_type(record)
          end

          private

          def validate_type(record)
            value = record.data[:type]
            (record.errors.add :type, 'blank') && return if value.blank?

            record.errors.add :type, value unless %w[compensation pension].include?(value)
          end
        end
      end
    end
  end
end
