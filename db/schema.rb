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

ActiveRecord::Schema.define(version: 20140819063743) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pg_trgm"

  create_table "active_admin_comments", force: true do |t|
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

  create_table "addresses", force: true do |t|
    t.string   "flat"
    t.string   "building"
    t.string   "street"
    t.string   "area"
    t.string   "town"
    t.string   "state"
    t.string   "pin"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "admin_users", force: true do |t|
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

  create_table "banks", force: true do |t|
    t.string  "name"
    t.boolean "is_joint"
    t.integer "startup_id"
  end

  add_index "banks", ["startup_id"], name: "index_banks_on_startup_id", using: :btree

  create_table "categories", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "category_type"
  end

  add_index "categories", ["category_type"], name: "index_categories_on_category_type", using: :btree

  create_table "categories_users", id: false, force: true do |t|
    t.integer "category_id"
    t.integer "user_id"
  end

  create_table "connections", force: true do |t|
    t.integer  "user_id"
    t.integer  "contact_id"
    t.string   "direction"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "db_configs", force: true do |t|
    t.string   "key"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "events", force: true do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "start_at"
    t.datetime "end_at"
    t.integer  "location_id"
    t.boolean  "featured"
    t.integer  "category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "picture"
    t.integer  "user_id"
    t.boolean  "notification_sent"
  end

  add_index "events", ["category_id"], name: "index_events_on_category_id", using: :btree
  add_index "events", ["location_id"], name: "index_events_on_location_id", using: :btree
  add_index "events", ["user_id"], name: "index_events_on_user_id", using: :btree

  create_table "guardians", force: true do |t|
    t.integer  "name_id"
    t.integer  "address_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "guardians", ["address_id"], name: "index_guardians_on_address_id", using: :btree
  add_index "guardians", ["name_id"], name: "index_guardians_on_name_id", using: :btree

  create_table "locations", force: true do |t|
    t.decimal  "latitude"
    t.decimal  "longitude"
    t.string   "title"
    t.text     "address"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "names", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "middle_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "salutation"
  end

  create_table "news", force: true do |t|
    t.string   "title"
    t.text     "body"
    t.integer  "user_id"
    t.boolean  "featured"
    t.string   "youtube_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "picture"
    t.boolean  "notification_sent"
    t.datetime "published_at"
    t.integer  "category_id"
  end

  add_index "news", ["user_id"], name: "index_news_on_user_id", using: :btree

  create_table "requests", force: true do |t|
    t.text     "body"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "social_ids", force: true do |t|
    t.string   "provider"
    t.integer  "user_id"
    t.string   "social_id"
    t.string   "social_token", limit: 500
    t.boolean  "primary"
    t.string   "permission"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "social_ids", ["user_id"], name: "index_social_ids_on_user_id", using: :btree

  create_table "startup_applications", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "phone"
    t.text     "idea"
    t.string   "website"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "startups", force: true do |t|
    t.string   "name"
    t.string   "logo"
    t.string   "pitch"
    t.string   "website"
    t.text     "about"
    t.string   "email"
    t.string   "phone"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "facebook_link"
    t.string   "twitter_link"
    t.boolean  "dsc"
    t.string   "authorized_capital"
    t.string   "share_holding_pattern"
    t.string   "moa"
    t.text     "police_station"
    t.boolean  "incorporation_status",    default: false
    t.boolean  "bank_status",             default: false
    t.boolean  "sep_status",              default: false
    t.text     "company_names"
    t.text     "address"
    t.string   "pre_funds"
    t.text     "startup_before"
    t.string   "help_from_sv"
    t.integer  "registered_address_id"
    t.string   "pre_investers_name"
    t.string   "transaction_details"
    t.boolean  "partnership_application"
    t.string   "registration_type"
    t.string   "approval_status"
    t.string   "product_name"
    t.string   "product_description"
    t.string   "cool_fact"
    t.string   "state"
    t.string   "district"
  end

  add_index "startups", ["registered_address_id"], name: "index_startups_on_registered_address_id", using: :btree

  create_table "startups_categories", id: false, force: true do |t|
    t.integer "startup_id"
    t.integer "category_id"
  end

  create_table "student_entrepreneur_policies", force: true do |t|
    t.string   "certificate_pic"
    t.text     "address"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "university_registration_number"
    t.boolean  "status"
  end

  add_index "student_entrepreneur_policies", ["user_id"], name: "index_student_entrepreneur_policies_on_user_id", using: :btree

  create_table "taggings", force: true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree

  create_table "tags", force: true do |t|
    t.string  "name"
    t.integer "taggings_count", default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "users", force: true do |t|
    t.string   "username"
    t.string   "email"
    t.string   "fullname"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "avatar"
    t.string   "encrypted_password",            default: ""
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                 default: 0,     null: false
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
    t.integer  "startup_link_verifier_id"
    t.string   "startup_verifier_token"
    t.boolean  "is_founder"
    t.string   "pan"
    t.string   "din"
    t.string   "aadhaar"
    t.integer  "address_id"
    t.integer  "father_id"
    t.boolean  "is_director",                   default: false
    t.string   "mother_maiden_name"
    t.boolean  "married"
    t.string   "current_occupation"
    t.text     "educational_qualification"
    t.string   "place_of_birth"
    t.string   "religion"
    t.integer  "guardian_id"
    t.integer  "bank_id"
    t.string   "salutation"
    t.integer  "number_of_shares"
    t.boolean  "is_share_holder"
    t.boolean  "is_student"
    t.string   "college"
    t.string   "university"
    t.string   "course"
    t.string   "semester"
    t.boolean  "startup_form_link_sent_status"
    t.string   "gender"
    t.string   "phone"
    t.text     "communication_address"
    t.boolean  "phone_verified",                default: false
    t.string   "phone_verification_code"
    t.integer  "pending_startup_id"
    t.string   "company"
    t.string   "designation"
    t.boolean  "is_contact"
    t.boolean  "managing_director",             default: false
    t.boolean  "operate_bank_account",          default: false
    t.integer  "share_percentage"
    t.integer  "cash_contribution"
    t.integer  "salary"
  end

  add_index "users", ["address_id"], name: "index_users_on_address_id", using: :btree
  add_index "users", ["bank_id"], name: "index_users_on_bank_id", using: :btree
  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["father_id"], name: "index_users_on_father_id", using: :btree
  add_index "users", ["guardian_id"], name: "index_users_on_guardian_id", using: :btree
  add_index "users", ["invitation_token"], name: "index_users_on_invitation_token", unique: true, using: :btree
  add_index "users", ["invited_by_id"], name: "index_users_on_invited_by_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "versions", force: true do |t|
    t.string   "item_type",      null: false
    t.integer  "item_id",        null: false
    t.string   "event",          null: false
    t.string   "whodunnit"
    t.text     "object"
    t.text     "object_changes"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

end
