class CreateOperationalProbes < ActiveRecord::Migration[8.1]
  def change
    create_table :operational_probes do |t|
      t.string :nonce, null: false
      t.timestamps

      t.index :nonce, unique: true
    end
  end
end
