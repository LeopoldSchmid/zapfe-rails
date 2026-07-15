class CreateHelpCenter < ActiveRecord::Migration[8.1]
  def change
    create_table :help_articles do |t|
      t.string :topic, null: false
      t.string :title, null: false
      t.timestamps
    end
    add_index :help_articles, :topic, unique: true

    create_table :help_faqs do |t|
      t.references :help_article, null: false, foreign_key: true
      t.string :question, null: false
      t.text :answer, null: false
      t.integer :position, null: false, default: 1
      t.timestamps
    end

    create_table :help_requests do |t|
      t.references :admin_user, null: false, foreign_key: true
      t.references :help_article, foreign_key: true
      t.string :topic, null: false
      t.string :page_path, null: false
      t.string :subject, null: false
      t.text :message, null: false
      t.string :status, null: false, default: "open"
      t.timestamps
    end
    add_index :help_requests, :status
  end
end
