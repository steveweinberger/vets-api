# frozen_string_literal: true

require 'common/client/base'
require_relative 'configuration'
require_relative 'get_debts_response'

module Debts
  class Service < Debts::BaseService
    attr_reader :file_number

    include Common::Client::Concerns::Monitoring

    configuration Debts::Configuration

    STATSD_KEY_PREFIX = 'api.debts'

    def initialize(user)
      super(user)
      @debts = init_debts
    end

    def get_debts
      {
        has_dependent_debts: veteran_has_dependent_debts?,
        debts: debts_with_sorted_histories
      }
    end

    def veteran_has_dependent_debts?
      @debts.any? { |debt| debt['payeeNumber'] != '00' }
    end

    private

    def init_file_number
      bgs_file_number = BGS::PeopleService.new(@user).find_person_by_participant_id[:file_nbr]
      bgs_file_number.presence || @user.ssn
    end

    def debts_with_sorted_histories
      @debts.select do |debt|
        debt['debtHistory'] = sort_by_date(debt['debtHistory'])
        debt['payeeNumber'] == '00'
      end
    end

    def init_debts
      with_monitoring_and_error_handling do
        GetDebtsResponse.new(perform(:post, 'letterdetails/get', fileNumber: @file_number).body).debts
      end
    end

    def sort_by_date(debt_history)
      debt_history.sort_by { |d| Date.strptime(d['date'], '%m/%d/%Y') }.reverse
    end
  end
end
