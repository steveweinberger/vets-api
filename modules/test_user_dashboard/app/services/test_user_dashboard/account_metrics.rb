# frozen_string_literal: true

module TestUserDashboard
  class AccountMetrics
    TABLE = 'tud_accounts_usage'

    attr_reader :tud_account

    def initialize(user)
      @tud_account = TudAccount.find_by(account_uuid: user.account_uuid)
    end

    def checkin(checkin_time:, is_manual_checkin: false)
      return unless tud_account

      row = { checkin_time: checkin_time, is_manual_checkin: is_manual_checkin }

      TestUserDashboard::BigQuery.new.insert_into(table_name: TABLE, rows: [row])
    end

    def checkout
      return unless tud_account

      record = TestUserDashboard::TudAccountCheckout
        .where(account_uuid: tud_account.account_uuid)
        .last

      binding.pry

      record.update(has_checkin_error: true) if record.present? && record.checkin_time.nil?

      TestUserDashboard::TudAccountCheckout.create(
        account_uuid: tud_account.account_uuid,
        checkout_time: Time.now.utc
      )
    end
  end
end
