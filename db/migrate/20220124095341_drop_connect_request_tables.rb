class DropConnectRequestTables < ActiveRecord::Migration[6.1]
  def up
    drop_table :connect_requests
    drop_table :connect_slots
  end

  def down
    create_table :connect_slots do |t|
      t.references :faculty, index: true, foreign_key: true
      t.datetime :slot_at

      t.timestamps null: false
    end

    create_table :connect_requests do |t|
      t.references :connect_slot, index: true, foreign_key: true
      t.references :startup, index: true, foreign_key: true
      t.text :questions
      t.string :status
      t.string :meeting_link
      t.datetime :confirmed_at
      t.datetime :feedback_mails_sent_at
      t.integer :rating_for_faculty
      t.integer :rating_for_team
      t.text :comment_for_faculty
      t.text :comment_for_team
      t.timestamps null: false
    end
  end
end
