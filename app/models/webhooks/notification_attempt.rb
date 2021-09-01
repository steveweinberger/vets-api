# frozen_string_literal: true

module Webhooks
  class NotificationAttempt < ApplicationRecord
    self.table_name = 'webhooks_notification_attempts'

    RESPONSE_STATUS = 'status'
    RESPONSE_BODY = 'body'
    RESPONSE_EXCEPTION = 'exception'
    RESPONSE_EXCEPTION_TYPE = 'type'
    RESPONSE_EXCEPTION_MESSAGE = 'message'

    has_many :webhooks_notification_attempt_assocs,
             class_name: 'Webhooks::NotificationAttemptAssoc',
             foreign_key: :webhooks_notification_attempt_id,
             inverse_of: :webhooks_notification_attempt_assocs,
             dependent: :destroy

    has_many :webhooks_notifications,
             class_name: 'Webhooks::Notification',
             through: :webhooks_notification_attempt_assocs
  end
end
