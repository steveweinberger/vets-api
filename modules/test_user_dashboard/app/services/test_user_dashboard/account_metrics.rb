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

      bigquery = TestUserDashboard::BigQuery.new

      tuple = bigquery.select_all(
        table_name: TABLE,
        where: "WHERE account_uuid='#{tud_account.account_uuid}'",
        order_by: 'ORDER BY created_at DESC',
        limit: 'LIMIT 1'
      )[0]

      if tuple.present? && tuple[:checkin_time].nil?
        bigquery.update(
          table_name: TABLE,
          set: 'SET has_checkin_error=TRUE',
          where: "WHERE account_uuid='#{tuple[:account_uuid]}' AND UNIX_MILLIS(created_at)=#{(tuple[:created_at].to_f * 1000).to_i}"
        )
      end

      now = Time.now.utc

      row = {
        account_uuid: tud_account.account_uuid,
        checkout_time: now,
        created_at: now
      }

      bigquery.insert_into(table_name: TABLE, rows: [row])
    end
  end
end
