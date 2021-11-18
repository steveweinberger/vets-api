# frozen_string_literal: true

module TestUserDashboard
  class MirrorAccountCheckoutsInBigQuery
    include Sidekiq::Worker

    TUD_ACCOUNTS_USAGE_TABLE = 'tud_accounts_usage'

    def perform
      mirror_account_checkouts_in_bigquery
    end

    private

    def mirror_account_checkouts_in_bigquery
      client = TestUserDashboard::BigQuery.new
      client.delete_from(table_name: TUD_ACCOUNTS_USAGE_TABLE)
      client.insert_into(table_name: TUD_ACCOUNTS_USAGE_TABLE, rows: checkouts)
      puts "Mirrored TUD_ACCOUNTS_USAGE_TABLE"
    end

    def checkouts
      TestUserDashboard::TudAccountCheckout.all.each.with_object([]) do |account, rows|
        rows << account.attributes.reject { |attr, _| attr == 'id' }
      end
    end
  end
end
