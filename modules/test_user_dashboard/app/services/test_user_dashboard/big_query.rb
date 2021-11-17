# frozen_string_literal: true

require 'sentry_logging'
require 'google/cloud/bigquery'

module TestUserDashboard
  class BigQuery
    include SentryLogging

    PROJECT = 'vsp-analytics-and-insights'
    DATASET = 'vsp_testing_tools'

    attr_reader :bigquery

    def initialize
      @bigquery = Google::Cloud::Bigquery.new
    rescue => e
      log_exception_to_sentry(e)
    end

    def select_all(table_name:, where: nil, order_by: nil, limit: nil)
      clauses = [where, order_by, limit]
                .reject(&:nil?)
                .join(' ')

      sql = if clauses.empty?
              "SELECT * FROM `#{PROJECT}.#{DATASET}.#{table_name}`"
            else
              "SELECT * FROM `#{PROJECT}.#{DATASET}.#{table_name}` " \
                "#{clauses}"
            end

      query(sql)
    end

    def update(table_name:, set:, where: nil)
      clauses = [set, where].reject(&:nil?).join(' ')

      sql = "UPDATE `#{PROJECT}.#{DATASET}.#{table_name}` #{clauses}"

      query(sql)
    end

    # BigQuery requires a row indentifier in DELETE FROM statements
    def delete_from(table_name:, where:)
      sql = "DELETE FROM `#{PROJECT}.#{DATASET}.#{table_name}` #{where}"

      query(sql)
    end

    # # BigQuery requires a row indentifier in DELETE FROM statements
    # def delete_from(table_name:, row_identifier: 'account_uuid')
    #   sql = "DELETE FROM `#{PROJECT}.#{DATASET}.#{table_name}` " \
    #         "WHERE #{row_identifier} IS NOT NULL"

    #   query(sql)
    # end

    def insert_into(table_name:, rows:)
      # rubocop:disable Rails/SkipsModelValidations
      table(table_name: table_name).insert rows
      # rubocop:enable Rails/SkipsModelValidations
    rescue => e
      log_exception_to_sentry(e)
    end

    private

    def dataset
      bigquery.dataset DATASET, skip_lookup: true
    end

    def table(table_name:)
      dataset.table table_name, skip_lookup: true
    end

    def query(sql)
      bigquery.query sql do |config|
        config.location = 'US'
      end
    rescue => e
      log_exception_to_sentry(e)
    end
  end
end
