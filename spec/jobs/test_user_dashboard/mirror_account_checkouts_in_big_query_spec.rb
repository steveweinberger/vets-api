# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TestUserDashboard::MirrorAccountCheckoutsInBigQuery do
  describe '#perform' do
    let!(:account) { create(:tud_account) }
    let!(:checkouts) { [create(:tud_account_checkout, account_uuid: account.account_uuid)] }

    let!(:client) do
      instance_double('TestUserDashboard::BigQuery',
                      delete_from: true,
                      insert_into: true)
    end

    before do
      allow(TestUserDashboard::BigQuery).to receive(:new).and_return(client)
      allow(TestUserDashboard::TudAccountCheckout).to receive(:all).and_return(checkouts)
    end

    it 'mirrors TUD accounts in BigQuery' do
      expect(client).to receive(:delete_from)
      expect(client).to receive(:insert_into)
      expect(TestUserDashboard::TudAccountCheckout).to receive(:all)
      described_class.new.perform
    end
  end
end
