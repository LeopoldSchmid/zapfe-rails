class CreatePushNotificationDeliveries < ActiveRecord::Migration[8.1]
  def change
    create_table :push_notification_deliveries do |t|
      t.references :task, null: false, foreign_key: true
      t.references :push_subscription, null: false, foreign_key: true
      t.string :kind, null: false
      t.date :notification_on, null: false
      t.string :status, null: false, default: "queued"
      t.integer :attempts, null: false, default: 0
      t.datetime :delivered_at
      t.datetime :failed_at
      t.string :last_error_class
      t.string :last_error_digest
      t.timestamps

      t.index [ :task_id, :push_subscription_id, :kind, :notification_on ],
        unique: true, name: "idx_push_deliveries_idempotency"
      t.index [ :status, :notification_on ]
    end
  end
end
