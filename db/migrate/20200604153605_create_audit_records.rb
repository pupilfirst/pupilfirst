class CreateAuditRecords < ActiveRecord::Migration[6.0]
  def change
    create_table :audit_records do |t|
      t.references :school, null: false
      t.string :audit_type, null: false
      t.jsonb :metadata, default: {}
      t.timestamps
    end
  end
end
