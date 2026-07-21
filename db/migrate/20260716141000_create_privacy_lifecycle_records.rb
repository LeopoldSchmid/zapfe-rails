class CreatePrivacyLifecycleRecords < ActiveRecord::Migration[8.1]
  def change
    create_table :privacy_legal_holds do |t|
      t.string :subject_digest, null: false
      t.text :reason, null: false
      t.datetime :expires_at
      t.integer :created_by_id, null: false
      t.datetime :released_at
      t.integer :released_by_id
      t.timestamps

      t.index :subject_digest
      t.index :expires_at
      t.index :released_at
      t.foreign_key :admin_users, column: :created_by_id
      t.foreign_key :admin_users, column: :released_by_id
    end

    create_table :privacy_erasure_tombstones do |t|
      t.string :subject_digest, null: false
      t.json :erased_records, null: false, default: {}
      t.datetime :erased_at, null: false
      t.integer :performed_by_id, null: false
      t.timestamps

      t.index :subject_digest
      t.index :erased_at
      t.foreign_key :admin_users, column: :performed_by_id
    end
  end
end
