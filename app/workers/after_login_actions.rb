# frozen_string_literal: true

class AfterLoginActions
  include Accountable
  include Sidekiq::MeasureRunTime

  def initialize(user)
    @current_user = user
  end

  def perform
    measure_run_time do
      return unless @current_user

      evss_create_account
      create_user_account
      update_account_login_stats
      if Settings.test_user_dashboard.env == 'staging'
        TestUserDashboard::UpdateUser.new(@current_user).call(Time.current)
      end
    end
  end

  private

  def evss_create_account
    if @current_user.authorize(:evss, :access?)
      auth_headers = EVSS::AuthHeaders.new(@current_user).to_h
      EVSS::CreateUserAccountJob.perform_async(auth_headers)
    end
  end
end
