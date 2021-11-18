# frozen_string_literal: true

require 'rails_helper'

describe TestUserDashboard::AccountMetrics do
  describe '#initialize' do
    let!(:user) { create(:user) }
    let!(:tud_account) { create(:tud_account, account_uuid: user.account_uuid) }
    let!(:last_record) { nil }

    before do
      allow(TestUserDashboard::TudAccount).to receive(:find_by).and_return(tud_account)
      # rubocop:disable RSpec/MessageChain
      allow(TestUserDashboard::TudAccountCheckout).to receive_message_chain(:where, :last).and_return(last_record)
      # rubocop:enable RSpec/MessageChain
    end

    it 'instantiates the test account by account_uuid' do
      metrics = TestUserDashboard::AccountMetrics.new(user)
      expect(metrics.tud_account[:account_uuid]).to eq(user.account_uuid)
      expect(metrics.last_record).to be_nil

      # rubocop:disable RSpec/MessageChain
      expect(TestUserDashboard::TudAccountCheckout).to receive_message_chain(:where, :last)
      # rubocop:enable RSpec/MessageChain
      described_class.new(user)
    end
  end

  describe '#checkin' do
    let!(:user) { create(:user) }
    let!(:tud_account) { nil }

    context 'TUD account does not exist' do
      before do
        allow(TestUserDashboard::TudAccount).to receive(:find_by).and_return(nil)
        # rubocop:disable RSpec/MessageChain
        allow(TestUserDashboard::TudAccountCheckout).to receive_message_chain(:where, :last).and_return(nil)
        # rubocop:enable RSpec/MessageChain
      end

      it 'returns nil' do
        expect(TestUserDashboard::AccountMetrics.new(user).checkin).to be_nil
      end
    end

    context 'TUD account does exist' do
      let!(:user) { create(:user) }
      let(:tud_account) { create(:tud_account, account_uuid: user.account_uuid) }
      let(:last_record) { create(:tud_account_checkout, account_uuid: user.account_uuid) }

      before do
        allow(TestUserDashboard::TudAccount).to receive(:find_by).and_return(tud_account)
        # rubocop:disable RSpec/MessageChain
        allow(TestUserDashboard::TudAccountCheckout).to receive_message_chain(:where, :last).and_return(last_record)
        # rubocop:enable RSpec/MessageChain
      end

      it 'pushes the event data to BigQuery' do
        metrics = described_class.new(user)
        metrics.checkin
        expect(metrics.last_record.checkin_time).not_to be_nil
        expect(metrics.last_record.is_manual_checkin).to be(false)
      end
    end
  end

  describe '#checkout' do
    let!(:user) { create(:user) }
    let!(:tud_account) { nil }

    context 'TUD account does not exist' do
      before do
        allow(TestUserDashboard::TudAccount).to receive(:find_by).and_return(nil)
        # rubocop:disable RSpec/MessageChain
        allow(TestUserDashboard::TudAccountCheckout).to receive_message_chain(:where, :last).and_return(nil)
        # rubocop:enable RSpec/MessageChain
      end

      it 'returns nil' do
        expect(TestUserDashboard::AccountMetrics.new(user).checkout).to be_nil
      end
    end

    context 'TUD account does exist' do
      let!(:user) { create(:user) }
      let(:tud_account) { create(:tud_account, account_uuid: user.account_uuid) }
      let(:last_record) { create(:tud_account_checkout, account_uuid: user.account_uuid) }

      before do
        allow(TestUserDashboard::TudAccount).to receive(:find_by).and_return(tud_account)
        # rubocop:disable RSpec/MessageChain
        allow(TestUserDashboard::TudAccountCheckout).to receive_message_chain(:where, :last).and_return(last_record)
        # rubocop:enable RSpec/MessageChain
      end

      it 'pushes the event data to BigQuery' do
        checkout_return_value = described_class.new(user).checkout
        expect(checkout_return_value.is_a?(TestUserDashboard::TudAccountCheckout)).to be(true)
        expect(checkout_return_value.checkin_time).to be_nil
        expect(checkout_return_value.has_checkin_error).to be_nil
      end
    end
  end
end
