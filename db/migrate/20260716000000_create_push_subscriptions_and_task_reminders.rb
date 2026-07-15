class CreatePushSubscriptionsAndTaskReminders < ActiveRecord::Migration[8.1]
  def change
    create_table :push_subscriptions do |t|
      t.references :admin_user, null: false, foreign_key: true
      t.text :endpoint, null: false
      t.text :p256dh, null: false
      t.text :auth, null: false
      t.timestamps
    end
    add_index :push_subscriptions, :endpoint, unique: true

    add_column :tasks, :last_push_reminded_on, :date
  end
end
