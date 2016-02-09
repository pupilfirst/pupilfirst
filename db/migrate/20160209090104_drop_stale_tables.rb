class DropStaleTables < ActiveRecord::Migration
  def self.up
    drop_table :mentor_meetings
    drop_table :mentor_skills
    drop_table :mentors
    drop_table :startup_applications
  end

  def self.down
    create_table :mentor_meetings do |t|
      t.integer  "user_id"
      t.integer  "mentor_id"
      t.string   "purpose"
      t.datetime "meeting_at"
      t.integer  "duration"
      t.string   "status",               default: "requested"
      t.integer  "mentor_rating"
      t.integer  "user_rating"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.datetime "suggested_meeting_at"
      t.text     "user_comments"
      t.text     "mentor_comments"
      t.datetime "user_sms_sent_at"
      t.datetime "mentor_sms_sent_at"
    end

    create_table :mentor_skills do |t|
      t.integer  "mentor_id"
      t.integer  "skill_id"
      t.string   "expertise"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table :mentors do |t|
      t.integer  "user_id"
      t.string   "availability"
      t.string   "company_level"
      t.datetime "verified_at"
      t.string   "company"
    end

    create_table :startup_applications do |t|
      t.string   "name"
      t.string   "email"
      t.string   "phone"
      t.text     "idea"
      t.string   "website"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
