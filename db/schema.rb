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

ActiveRecord::Schema.define(version: 20150226094832) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pg_trgm"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string   "namespace",     limit: 255
    t.text     "body"
    t.string   "resource_id",   limit: 255, null: false
    t.string   "resource_type", limit: 255, null: false
    t.integer  "author_id"
    t.string   "author_type",   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

  create_table "addresses", force: :cascade do |t|
    t.string   "flat",       limit: 255
    t.string   "building",   limit: 255
    t.string   "street",     limit: 255
    t.string   "area",       limit: 255
    t.string   "town",       limit: 255
    t.string   "state",      limit: 255
    t.string   "pin",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "admin_users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username",               limit: 255
    t.string   "avatar",                 limit: 255
    t.string   "fullname",               limit: 255
    t.string   "admin_type",             limit: 255
  end

  add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true, using: :btree
  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true, using: :btree

  create_table "banks", force: :cascade do |t|
    t.string  "name",       limit: 255
    t.boolean "is_joint"
    t.integer "startup_id"
  end

  add_index "banks", ["startup_id"], name: "index_banks_on_startup_id", using: :btree

  create_table "categories", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "category_type", limit: 255
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

  create_table "connections", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "contact_id"
    t.string   "direction",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "db_configs", force: :cascade do |t|
    t.string   "key",        limit: 255
    t.string   "value",      limit: 255
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

  create_table "events", force: :cascade do |t|
    t.string   "title",                      limit: 255
    t.text     "description"
    t.datetime "start_at"
    t.datetime "end_at"
    t.string   "location"
    t.boolean  "featured"
    t.integer  "category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "picture",                    limit: 255
    t.integer  "user_id"
    t.boolean  "notification_sent"
    t.boolean  "approved",                               default: false
    t.string   "posters_name"
    t.string   "posters_email"
    t.string   "posters_phone_number"
    t.boolean  "approval_notification_sent",             default: false
  end

  add_index "events", ["category_id"], name: "index_events_on_category_id", using: :btree
  add_index "events", ["location"], name: "index_events_on_location", using: :btree
  add_index "events", ["user_id"], name: "index_events_on_user_id", using: :btree

  create_table "guardians", force: :cascade do |t|
    t.integer  "name_id"
    t.integer  "address_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "guardians", ["address_id"], name: "index_guardians_on_address_id", using: :btree
  add_index "guardians", ["name_id"], name: "index_guardians_on_name_id", using: :btree

  create_table "locations", force: :cascade do |t|
    t.decimal  "latitude"
    t.decimal  "longitude"
    t.string   "title",      limit: 255
    t.text     "address"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mentor_meetings", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "mentor_id"
    t.string   "purpose",              limit: 255
    t.datetime "meeting_at"
    t.integer  "duration"
    t.string   "status",               limit: 255, default: "requested"
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
    t.string   "expertise",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "mentor_skills", ["mentor_id"], name: "index_mentor_skills_on_mentor_id", using: :btree
  add_index "mentor_skills", ["skill_id"], name: "index_mentor_skills_on_skill_id", using: :btree

  create_table "mentors", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "availability",  limit: 255
    t.string   "company_level", limit: 255
    t.datetime "verified_at"
    t.integer  "company_id"
    t.string   "company"
  end

  add_index "mentors", ["company_id"], name: "index_mentors_on_company_id", using: :btree

  create_table "names", force: :cascade do |t|
    t.string   "first_name",  limit: 255
    t.string   "last_name",   limit: 255
    t.string   "middle_name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "salutation",  limit: 255
  end

  create_table "news", force: :cascade do |t|
    t.string   "title",             limit: 255
    t.text     "body"
    t.integer  "user_id"
    t.boolean  "featured"
    t.string   "youtube_id",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "picture",           limit: 255
    t.boolean  "notification_sent"
    t.datetime "published_at"
    t.integer  "category_id"
  end

  add_index "news", ["user_id"], name: "index_news_on_user_id", using: :btree

  create_table "partnerships", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "startup_id"
    t.integer  "salary"
    t.integer  "cash_contribution"
    t.boolean  "managing_partner"
    t.boolean  "operate_bank_account"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "share_percentage",                         precision: 5, scale: 2
    t.datetime "confirmed_at"
    t.string   "confirmation_token",           limit: 255
    t.integer  "bank_account_operation_limit"
  end

  add_index "partnerships", ["startup_id"], name: "index_partnerships_on_startup_id", using: :btree
  add_index "partnerships", ["user_id"], name: "index_partnerships_on_user_id", using: :btree

  create_table "requests", force: :cascade do |t|
    t.text     "body"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "social_ids", force: :cascade do |t|
    t.string   "provider",     limit: 255
    t.integer  "user_id"
    t.string   "social_id",    limit: 255
    t.string   "social_token", limit: 500
    t.boolean  "primary"
    t.string   "permission",   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "social_ids", ["user_id"], name: "index_social_ids_on_user_id", using: :btree

  create_table "startup_applications", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "email",      limit: 255
    t.string   "phone",      limit: 255
    t.text     "idea"
    t.string   "website",    limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "startup_jobs", force: :cascade do |t|
    t.integer  "startup_id"
    t.string   "title"
    t.text     "description"
    t.integer  "salary_max"
    t.integer  "salary_min"
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
  end

  add_index "startup_jobs", ["startup_id"], name: "index_startup_jobs_on_startup_id", using: :btree

  create_table "startup_links", force: :cascade do |t|
    t.integer  "startup_id"
    t.string   "name",        limit: 255
    t.string   "url",         limit: 255
    t.string   "description", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "startup_links", ["startup_id"], name: "index_startup_links_on_startup_id", using: :btree

  create_table "startups", force: :cascade do |t|
    t.string   "name",                      limit: 255
    t.string   "logo",                      limit: 255
    t.string   "pitch",                     limit: 255
    t.string   "website",                   limit: 255
    t.text     "about"
    t.string   "email",                     limit: 255
    t.string   "phone",                     limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "facebook_link",             limit: 255
    t.string   "twitter_link",              limit: 255
    t.boolean  "dsc"
    t.string   "authorized_capital",        limit: 255
    t.string   "share_holding_pattern",     limit: 255
    t.string   "moa",                       limit: 255
    t.text     "police_station"
    t.boolean  "incorporation_status",                  default: false
    t.boolean  "bank_status",                           default: false
    t.boolean  "sep_status",                            default: false
    t.text     "company_names"
    t.text     "address"
    t.string   "pre_funds",                 limit: 255
    t.text     "startup_before"
    t.string   "help_from_sv",              limit: 255
    t.integer  "registered_address_id"
    t.string   "pre_investers_name",        limit: 255
    t.string   "transaction_details",       limit: 255
    t.boolean  "partnership_application"
    t.string   "registration_type",         limit: 255
    t.string   "approval_status",           limit: 255, default: "unready"
    t.string   "product_name",              limit: 255
    t.string   "product_description",       limit: 255
    t.string   "cool_fact",                 limit: 255
    t.string   "state",                     limit: 255
    t.string   "district",                  limit: 255
    t.integer  "total_shares"
    t.string   "product_progress",          limit: 255
    t.string   "presentation_link",         limit: 255
    t.integer  "revenue_generated"
    t.integer  "team_size"
    t.integer  "women_employees"
    t.string   "incubation_location",       limit: 255
    t.boolean  "agreement_sent",                        default: false
    t.string   "pin",                       limit: 255
    t.datetime "agreement_first_signed_at"
    t.datetime "agreement_last_signed_at"
    t.datetime "agreement_ends_at"
    t.boolean  "physical_incubatee"
  end

  add_index "startups", ["registered_address_id"], name: "index_startups_on_registered_address_id", using: :btree

  create_table "statistics", force: :cascade do |t|
    t.string   "parameter",           limit: 255
    t.text     "statistic"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "incubation_location", limit: 255
  end

  add_index "statistics", ["parameter"], name: "index_statistics_on_parameter", using: :btree

  create_table "student_entrepreneur_policies", force: :cascade do |t|
    t.string   "certificate_pic",                limit: 255
    t.text     "address"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "university_registration_number", limit: 255
    t.boolean  "status"
  end

  add_index "student_entrepreneur_policies", ["user_id"], name: "index_student_entrepreneur_policies_on_user_id", using: :btree

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type", limit: 255
    t.integer  "tagger_id"
    t.string   "tagger_type",   limit: 255
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree

  create_table "tags", force: :cascade do |t|
    t.string  "name",           limit: 255
    t.integer "taggings_count",             default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "username",                      limit: 255
    t.string   "email",                         limit: 255
    t.string   "fullname",                      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "avatar",                        limit: 255
    t.string   "encrypted_password",            limit: 255, default: ""
    t.string   "reset_password_token",          limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                             default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",            limit: 255
    t.string   "last_sign_in_ip",               limit: 255
    t.string   "confirmation_token",            limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email",             limit: 255
    t.string   "invitation_token",              limit: 255
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type",               limit: 255
    t.integer  "startup_id"
    t.string   "title",                         limit: 255
    t.string   "linkedin_url",                  limit: 255
    t.string   "twitter_url",                   limit: 255
    t.date     "born_on"
    t.string   "auth_token",                    limit: 255
    t.integer  "startup_link_verifier_id"
    t.string   "startup_verifier_token",        limit: 255
    t.boolean  "is_founder"
    t.string   "pan",                           limit: 255
    t.string   "din",                           limit: 255
    t.string   "aadhaar",                       limit: 255
    t.integer  "address_id"
    t.integer  "father_id"
    t.string   "mother_maiden_name",            limit: 255
    t.boolean  "married"
    t.string   "current_occupation",            limit: 255
    t.text     "educational_qualification"
    t.string   "place_of_birth",                limit: 255
    t.string   "religion",                      limit: 255
    t.integer  "guardian_id"
    t.string   "salutation",                    limit: 255
    t.boolean  "is_student"
    t.string   "college",                       limit: 255
    t.string   "university",                    limit: 255
    t.string   "course",                        limit: 255
    t.string   "semester",                      limit: 255
    t.boolean  "startup_form_link_sent_status"
    t.string   "gender",                        limit: 255
    t.string   "phone",                         limit: 255
    t.text     "communication_address"
    t.boolean  "phone_verified",                            default: false
    t.string   "phone_verification_code",       limit: 255
    t.integer  "pending_startup_id"
    t.string   "company",                       limit: 255
    t.string   "designation",                   limit: 255
    t.boolean  "is_contact"
    t.boolean  "startup_admin"
    t.string   "father_or_husband_name",        limit: 255
    t.string   "pin",                           limit: 255
  end

  add_index "users", ["address_id"], name: "index_users_on_address_id", using: :btree
  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["father_id"], name: "index_users_on_father_id", using: :btree
  add_index "users", ["guardian_id"], name: "index_users_on_guardian_id", using: :btree
  add_index "users", ["invitation_token"], name: "index_users_on_invitation_token", unique: true, using: :btree
  add_index "users", ["invited_by_id"], name: "index_users_on_invited_by_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",      limit: 255, null: false
    t.integer  "item_id",                    null: false
    t.string   "event",          limit: 255, null: false
    t.string   "whodunnit",      limit: 255
    t.text     "object"
    t.text     "object_changes"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

end
