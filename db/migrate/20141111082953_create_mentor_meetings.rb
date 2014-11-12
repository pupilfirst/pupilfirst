class CreateMentorMeetings < ActiveRecord::Migration
  def change
    create_table :mentor_meetings do |t|
      t.references :user, index: true
      t.references :mentor, index: true
      t.string :purpose
      t.string :suggested_meeting_timings
      t.datetime :meeting_at
      t.integer :duration
      t.string :status
      t.integer :mentor_rating
      t.integer :user_rating

      t.timestamps
    end
  end
end
