# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150904194013) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pg_trgm"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

  create_table "admin_users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username"
    t.string   "avatar"
    t.string   "fullname"
    t.string   "admin_type"
  end

  add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true, using: :btree
  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true, using: :btree

  create_table "categories", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "category_type"
  end

  add_index "categories", ["category_type"], name: "index_categories_on_category_type", using: :btree

  create_table "categories_startups", id: false, force: :cascade do |t|
    t.integer "startup_id"
    t.integer "category_id"
  end

  create_table "categories_users", id: false, force: :cascade do |t|
    t.integer "category_id"
    t.integer "user_id"
  end

  create_table "colleges", force: :cascade do |t|
    t.string   "name"
    t.string   "university"
    t.string   "city"
    t.string   "state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "db_configs", force: :cascade do |t|
    t.string   "key"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "karma_points", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "points"
    t.string   "activity_type"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "karma_points", ["user_id"], name: "index_karma_points_on_user_id", using: :btree

  create_table "mentor_meetings", force: :cascade do |t|
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

  add_index "mentor_meetings", ["mentor_id"], name: "index_mentor_meetings_on_mentor_id", using: :btree
  add_index "mentor_meetings", ["user_id"], name: "index_mentor_meetings_on_user_id", using: :btree

  create_table "mentor_skills", force: :cascade do |t|
    t.integer  "mentor_id"
    t.integer  "skill_id"
    t.string   "expertise"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "mentor_skills", ["mentor_id"], name: "index_mentor_skills_on_mentor_id", using: :btree
  add_index "mentor_skills", ["skill_id"], name: "index_mentor_skills_on_skill_id", using: :btree

  create_table "mentors", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "availability"
    t.string   "company_level"
    t.datetime "verified_at"
    t.string   "company"
  end

  create_table "startup_applications", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.string   "phone"
    t.text     "idea"
    t.string   "website"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "startup_feedback", force: :cascade do |t|
    t.text     "feedback"
    t.string   "reference_url"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "startup_id"
    t.datetime "send_at"
  end

  create_table "startup_jobs", force: :cascade do |t|
    t.integer  "startup_id"
    t.string   "title"
    t.text     "description"
    t.integer  "equity_max"
    t.integer  "equity_min"
    t.integer  "equity_vest"
    t.integer  "equity_cliff"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "expires_on"
    t.string   "location"
    t.string   "skills"
    t.string   "experience"
    t.string   "qualification"
    t.string   "contact_name"
    t.string   "contact_number"
    t.string   "contact_email"
    t.string   "salary"
  end

  add_index "startup_jobs", ["startup_id"], name: "index_startup_jobs_on_startup_id", using: :btree

  create_table "startups", force: :cascade do |t|
    t.string   "name"
    t.string   "logo"
    t.string   "pitch"
    t.string   "website"
    t.text     "about"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "facebook_link"
    t.string   "twitter_link"
    t.text     "address"
    t.string   "registration_type"
    t.string   "approval_status",           default: "unready"
    t.string   "product_name"
    t.text     "product_description"
    t.string   "cool_fact"
    t.string   "state"
    t.string   "district"
    t.string   "product_progress"
    t.string   "presentation_link"
    t.integer  "revenue_generated"
    t.integer  "team_size"
    t.integer  "women_employees"
    t.string   "incubation_location"
    t.boolean  "agreement_sent",            default: false
    t.string   "pin"
    t.datetime "agreement_first_signed_at"
    t.datetime "agreement_last_signed_at"
    t.datetime "agreement_ends_at"
    t.boolean  "physical_incubatee"
    t.text     "metadata"
    t.string   "slug"
    t.boolean  "featured"
    t.integer  "batch"
  end

  add_index "startups", ["batch"], name: "index_startups_on_batch", using: :btree
  add_index "startups", ["slug"], name: "index_startups_on_slug", unique: true, using: :btree

  create_table "timeline_event_types", force: :cascade do |t|
    t.string   "key"
    t.string   "title"
    t.text     "sample_text"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "badge"
    t.string   "role"
    t.string   "proof_required"
    t.string   "suggested_stage"
  end

  add_index "timeline_event_types", ["role"], name: "index_timeline_event_types_on_role", using: :btree

  create_table "timeline_events", force: :cascade do |t|
    t.integer  "iteration"
    t.text     "description"
    t.string   "image"
    t.integer  "startup_id"
    t.text     "links"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.date     "event_on"
    t.datetime "verified_at"
    t.integer  "timeline_event_type_id"
  end

  add_index "timeline_events", ["startup_id"], name: "index_timeline_events_on_startup_id", using: :btree
  add_index "timeline_events", ["timeline_event_type_id"], name: "index_timeline_events_on_timeline_event_type_id", using: :btree

  create_table "universities", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "location"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email"
    t.string   "fullname"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "avatar"
    t.string   "encrypted_password",       default: ""
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",            default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.integer  "startup_id"
    t.string   "title"
    t.string   "linkedin_url"
    t.string   "twitter_url"
    t.date     "born_on"
    t.string   "auth_token"
    t.boolean  "is_founder"
    t.string   "din"
    t.string   "aadhaar"
    t.string   "place_of_birth"
    t.string   "salutation"
    t.string   "course"
    t.string   "semester"
    t.string   "gender"
    t.string   "phone"
    t.text     "communication_address"
    t.string   "phone_verification_code"
    t.string   "company"
    t.boolean  "startup_admin"
    t.string   "father_or_husband_name"
    t.string   "pin"
    t.string   "district"
    t.string   "state"
    t.integer  "years_of_work_experience"
    t.integer  "year_of_graduation"
    t.integer  "college_id"
    t.string   "roll_number"
    t.string   "slack_username"
    t.integer  "university_id"
    t.string   "unconfirmed_phone"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["invitation_token"], name: "index_users_on_invitation_token", unique: true, using: :btree
  add_index "users", ["invited_by_id"], name: "index_users_on_invited_by_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["university_id"], name: "index_users_on_university_id", using: :btree

  add_foreign_key "karma_points", "users"
  add_foreign_key "timeline_events", "startups"
end
