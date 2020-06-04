class CreateAuditRecords < ActiveRecord::Migration[6.0]
  def change
    create_table :audit_records do |t|
      t.jsonb :data, default: {}
      t.timestamps
    end
  end
end
