# frozen_string_literal: true

module TestUserDashboard
  class AccountMetrics
    attr_reader :tud_account, :record

    def initialize(user)
      @tud_account = TudAccount.find_by(account_uuid: user.account_uuid)
      @record = last_tud_account_checkout_record
    end

    def checkin(checkin_time:, is_manual_checkin: false)
      return unless tud_account

      if record.present? && record.checkin_time.nil?
        record.update(checkin_time: checkin_time, is_manual_checkin: is_manual_checkin)
      end
    end

    def checkout
      return unless tud_account

      record.update(has_checkin_error: true) if record.present? && record.checkin_time.nil?

      TestUserDashboard::TudAccountCheckout.create(
        account_uuid: tud_account.account_uuid,
        checkout_time: Time.now.utc
      )
    end

    private

    def last_tud_account_checkout_record
      TestUserDashboard::TudAccountCheckout.where(account_uuid: tud_account.account_uuid).last
    end
  end
end
