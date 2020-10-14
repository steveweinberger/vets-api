# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FinancialStatusReport::Service do
  let(:file_number) { '796043735' }
  let(:user) { build(:user, :loa3, ssn: file_number) }
  let(:user_no_ssn) { build(:user, :loa3, ssn: '') }

  describe '#submit' do
    context 'with a valid file number' do
      it 'returns a 200' do
        VCR.use_cassette('bgs/people_service/person_data') do
          VCR.use_cassette('debts/financial_status_report/use_cassette') do
          end
        end
      end
    end

    context 'without a valid file number' do
      it 'returns a bad request error' do
        VCR.use_cassette('bgs/people_service/no_person_data') do
        end
      end
    end
  end
end
