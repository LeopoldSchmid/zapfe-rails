class VersionInquiryPrivacyNotices < ActiveRecord::Migration[8.1]
  def change
    add_column :inquiries, :privacy_notice_version, :string, null: false, default: "2026-07-16"
    add_column :inquiries, :privacy_notice_acknowledged_at, :datetime

    reversible do |direction|
      direction.up do
        execute <<~SQL.squish
          UPDATE inquiries
          SET privacy_notice_acknowledged_at = created_at
          WHERE privacy_accepted = 1 AND privacy_notice_acknowledged_at IS NULL
        SQL
      end
    end
  end
end
