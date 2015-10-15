class CreateConnectRequests < ActiveRecord::Migration
  def change
    create_table :connect_requests do |t|
      t.references :connect_slot, index: true, foreign_key: true
      t.references :startup, index: true, foreign_key: true
      t.text :questions
      t.string :status
      t.string :meeting_link

      t.timestamps null: false
    end
  end
end
