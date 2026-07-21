class CreateDocumentDeliveries < ActiveRecord::Migration[8.1]
  def change
    create_table :document_deliveries do |t|
      t.references :deliverable, polymorphic: true, null: false
      t.references :requested_by, null: false, foreign_key: { to_table: :admin_users }
      t.string :recipient, null: false
      t.string :status, null: false, default: "queued"
      t.string :idempotency_key, null: false
      t.string :provider_message_id
      t.integer :attempts, null: false, default: 0
      t.datetime :queued_at, null: false
      t.datetime :delivered_at
      t.datetime :failed_at
      t.string :last_error_class
      t.string :last_error_digest
      t.timestamps

      t.index :idempotency_key, unique: true
      t.index [ :status, :queued_at ]
    end
  end
end
