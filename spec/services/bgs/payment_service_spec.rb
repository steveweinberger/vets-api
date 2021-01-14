# frozen_string_literal: true

require 'rails_helper'

# outputs debug lines in specs
# "D, [2021-01-14T20:10:15.796296 #29] DEBUG -- : HTTPI /peer GET request to internal-dsva-vagov-dev-fwdproxy-1893365470.us-gov-west-1.elb.amazonaws.com (net_http)\n"

RSpec.describe BGS::PaymentService do
  let(:user) { FactoryBot.create(:evss_user, :loa3) }
  let(:person_hash) do
    {
      file_nbr: '796043735',
      ssn_nbr: '796043735',
      ptcpnt_id: '600061742'
    }
  end

  describe '#payment_history' do
    it 'returns a user\'s payment history given the user\'s participant id and file number' do
      VCR.use_cassette('bgs/payment_service/payment_history') do
        service = BGS::PaymentService.new(user)
        response = service.payment_history(person_hash)

        expect(response).to include(:payments)
      end
    end

    it 'returns an empty result if there are no results for the user' do
      VCR.use_cassette('bgs/payment_service/no_payment_history') do
        person_hash[:file_nbr] = '000000000'
        person_hash[:ptcpnt_id] = '000000000'

        response = BGS::PaymentService.new(user).payment_history(person_hash)
        expect(response).to include({ payments: [], return_payments: [] })
      end
    end

    context 'error' do
      it 'logs an error' do
        response = BGS::PaymentService.new(user)

        person_hash[:file_nbr] = '000000000'
        person_hash[:ptcpnt_id] = '000000000'
        expect_any_instance_of(BGS::PaymentInformationService)
          .to receive(:retrieve_payment_summary_with_bdn).and_raise(StandardError)
        expect(response).to receive(:log_exception_to_sentry)

        response.payment_history(person_hash)
      end
    end
  end
end
