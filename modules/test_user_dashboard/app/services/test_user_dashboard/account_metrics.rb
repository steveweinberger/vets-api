# frozen_string_literal: true

module TestUserDashboard
  class AccountMetrics
    TABLE = 'tud_accounts_usage'

    attr_reader :tud_account

    def initialize(user)
      @tud_account = TudAccount.find_by(account_uuid: user.account_uuid)
    end

    def checkin(checkin_time:, maintenance_update: false)
      return unless tud_account

      row = {
        account_uuid: tud_account.account_uuid,
        event: 'checkin',
        maintenance_update: maintenance_update,
        timestamp: checkin_time
      }

      TestUserDashboard::BigQuery.new.insert_into(table_name: TABLE, rows: [row])
    end

    def checkout
      return unless tud_account

      now = Time.now.utc

      row = {
        account_uuid: tud_account.account_uuid,
        checkout_time: now,
        created_at: now,
      }

      TestUserDashboard::BigQuery.new.insert_into(table_name: TABLE, rows: [row])
    end
  end
end
