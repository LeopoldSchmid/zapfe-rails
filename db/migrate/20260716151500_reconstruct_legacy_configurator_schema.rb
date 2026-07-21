class ReconstructLegacyConfiguratorSchema < ActiveRecord::Migration[8.1]
  def change
    create_table :solutions, if_not_exists: true do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.boolean :active, default: true, null: false
      t.integer :position, default: 0, null: false
      t.timestamps
      t.index :slug, unique: true
      t.index %i[active position]
    end

    create_table :solution_variants, if_not_exists: true do |t|
      t.integer :solution_id, null: false
      t.string :name, null: false
      t.string :slug, null: false
      t.integer :base_price_cents, default: 0, null: false
      t.text :metadata_json
      t.boolean :active, default: true, null: false
      t.integer :position, default: 0, null: false
      t.timestamps
      t.index :solution_id
      t.index %i[solution_id slug], unique: true
      t.index %i[solution_id active position]
    end

    create_table :scenes, if_not_exists: true do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :metadata_json
      t.boolean :active, default: true, null: false
      t.integer :position, default: 0, null: false
      t.timestamps
      t.index :slug, unique: true
      t.index %i[active position]
    end

    create_table :configuration_sessions, if_not_exists: true do |t|
      t.integer :solution_id, null: false
      t.integer :solution_variant_id, null: false
      t.integer :scene_id
      t.string :public_token, null: false
      t.string :status, default: "draft", null: false
      t.text :selected_options_json
      t.text :price_snapshot_json
      t.text :visual_snapshot_json
      t.text :customer_snapshot_json
      t.datetime :submitted_at
      t.timestamps
      t.index :public_token, unique: true
      t.index :solution_id
      t.index :solution_variant_id
      t.index :scene_id
      t.index :status
      t.index :submitted_at
    end
  end
end
