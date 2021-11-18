# frozen_string_literal: true

module TestUserDashboard
  class AccountMetrics
    attr_reader :tud_account, :record

    def initialize(user)
      @tud_account = TudAccount.find_by(account_uuid: user.account_uuid)
      @record = last_tud_account_checkout_record
    end

    def checkin(is_manual_checkin: false)
      return unless tud_account

      if last_checkin_time_nil?
        record.update(checkin_time: Time.now.utc, is_manual_checkin: is_manual_checkin)
      end
    end

    def checkout
      return unless tud_account

      if last_checkin_time_nil?
        record.update(has_checkin_error: true)
      end

      TestUserDashboard::TudAccountCheckout.create(
        account_uuid: tud_account.account_uuid,
        checkout_time: Time.now.utc
      )
    end

    private

    def last_tud_account_checkout_record
      TestUserDashboard::TudAccountCheckout.where(account_uuid: tud_account.account_uuid).last
    end

    def last_checkin_time_nil?
      record.present? && record.checkin_time.nil?
    end
  end
end
