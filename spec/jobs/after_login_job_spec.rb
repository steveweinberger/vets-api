# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AfterLoginJob do
  describe '#perform' do
    context 'with a user that has evss access' do
      let(:user) { create(:evss_user) }

      it 'launches CreateUserAccountJob' do
        expect(EVSS::CreateUserAccountJob).to receive(:perform_async)
        described_class.new.perform('user_uuid' => user.uuid)
      end
    end

    context 'with a user that doesnt have evss access' do
      let(:user) { create(:user) }

      it 'shouldnt launch CreateUserAccountJob' do
        expect(EVSS::CreateUserAccountJob).not_to receive(:perform_async)
        described_class.new.perform('user_uuid' => user.uuid)
      end
    end

    context 'in a non-staging environment' do
      let(:user) { create(:user) }

      around do |example|
        with_settings(Settings.test_user_dashboard, env: 'production') do
          example.run
        end
      end

      it 'does not call TUD account checkout' do
        expect_any_instance_of(TestUserDashboard::CheckoutUser).not_to receive(:call)
        described_class.new.perform('user_uuid' => user.uuid)
      end
    end

    context 'in a staging environment' do
      let(:user) { create(:user) }

      around do |example|
        with_settings(Settings.test_user_dashboard, env: 'staging') do
          example.run
        end
      end

      it 'calls TUD account checkout' do
        expect_any_instance_of(TestUserDashboard::CheckoutUser).to receive(:call)
        described_class.new.perform('user_uuid' => user.uuid)
      end
    end

    context 'saving account_login_stats' do
      let(:user) { create(:user) }
      let(:login_type) { 'myhealthevet' }

      before { allow_any_instance_of(UserIdentity).to receive(:sign_in).and_return(service_name: login_type) }

      context 'with non-existent login stats record' do
        it 'will create an account_login_stats record' do
          expect { described_class.new.perform('user_uuid' => user.uuid) }.to \
            change(AccountLoginStat, :count).by(1)
        end

        it 'will update the correct login stats column' do
          described_class.new.perform('user_uuid' => user.uuid)
          expect(AccountLoginStat.last.send("#{login_type}_at")).not_to be_nil
        end

        it 'will not create a record if login_type is not valid' do
          login_type = 'something_invalid'
          allow_any_instance_of(UserIdentity).to receive(:sign_in).and_return(service_name: login_type)

          expect { described_class.new.perform('user_uuid' => user.uuid) }.not_to \
            change(AccountLoginStat, :count)
        end
      end

      context 'with existing login stats record' do
        let(:account) { FactoryBot.create(:account) }

        before do
          allow_any_instance_of(User).to receive(:account) { account }
          AccountLoginStat.create(account_id: account.id, myhealthevet_at: 1.minute.ago)
        end

        it 'will not create another record' do
          expect { described_class.new.perform('user_uuid' => user.uuid) }.not_to \
            change(AccountLoginStat, :count)
        end

        it 'will overwrite existing value if login type was seen previously' do
          stat = AccountLoginStat.last

          expect do
            described_class.new.perform('user_uuid' => user.uuid)
            stat.reload
          end.to change(stat, :myhealthevet_at)
        end

        it 'will set new value in blank login column' do
          login_type = 'idme'
          allow_any_instance_of(UserIdentity).to receive(:sign_in).and_return(service_name: login_type)
          stat = AccountLoginStat.last

          expect do
            described_class.new.perform('user_uuid' => user.uuid)
            stat.reload
          end.not_to change(stat, :myhealthevet_at)

          expect(stat.idme_at).not_to be_blank
        end
      end
    end
  end
end
