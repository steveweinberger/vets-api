class CleanupWebhooks < ActiveRecord::Migration[6.1]
  remove_index :webhooks_notifications, name: "index_webhooks_subscription", if_exists: true
  remove_index :webhooks_notifications, name: "index_wh_notify", if_exists: true
  remove_index :webhooks_notifications, name: "index_wk_notify_processing", if_exists: true
  remove_index :webhooks_notification_attempt_assocs, name: 'index_wh_assoc_attempt_id', if_exists: true
  remove_index :webhooks_notification_attempt_assocs, name: 'index_wh_assoc_notification_id', if_exists: true

  drop_table(:webhooks_notification_attempt_assocs, if_exists: true)
  drop_table(:webhooks_notification_attempts, if_exists: true)
  drop_table(:webhooks_notifications, if_exists: true)
  drop_table(:webhooks_subscriptions, if_exists: true)
end
