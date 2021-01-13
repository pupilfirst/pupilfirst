class CreateConnectSlots < ActiveRecord::Migration[4.2]
  def change
    create_table :connect_slots do |t|
      t.references :faculty, index: true, foreign_key: true
      t.datetime :slot_at

      t.timestamps null: false
    end
  end
end
