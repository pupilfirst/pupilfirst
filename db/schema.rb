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

ActiveRecord::Schema.define(version: 20161203065011) do

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
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree
  end

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
    t.integer  "faculty_id"
    t.index ["email"], name: "index_admin_users_on_email", unique: true, using: :btree
    t.index ["faculty_id"], name: "index_admin_users_on_faculty_id", using: :btree
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true, using: :btree
  end

  create_table "ahoy_events", id: :uuid, default: nil, force: :cascade do |t|
    t.uuid     "visit_id"
    t.integer  "user_id"
    t.string   "user_type"
    t.string   "name"
    t.jsonb    "properties"
    t.datetime "time"
    t.index ["time"], name: "index_ahoy_events_on_time", using: :btree
    t.index ["user_id", "user_type"], name: "index_ahoy_events_on_user_id_and_user_type", using: :btree
    t.index ["visit_id"], name: "index_ahoy_events_on_visit_id", using: :btree
  end

  create_table "answer_options", force: :cascade do |t|
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.integer  "quiz_question_id"
    t.boolean  "correct_answer",   default: false
    t.string   "value"
    t.text     "hint_text"
    t.index ["quiz_question_id"], name: "index_answer_options_on_quiz_question_id", using: :btree
  end

  create_table "application_stages", force: :cascade do |t|
    t.string   "name"
    t.integer  "number"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.boolean  "final_stage"
  end

  create_table "application_submission_urls", force: :cascade do |t|
    t.string   "name"
    t.string   "url"
    t.integer  "score"
    t.integer  "application_submission_id"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "admin_user_id"
    t.index ["admin_user_id"], name: "index_application_submission_urls_on_admin_user_id", using: :btree
    t.index ["application_submission_id"], name: "index_application_submission_urls_on_application_submission_id", using: :btree
  end

  create_table "application_submissions", force: :cascade do |t|
    t.integer  "application_stage_id"
    t.integer  "batch_application_id"
    t.integer  "score"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.text     "notes"
    t.string   "file"
    t.text     "feedback_for_team"
    t.index ["application_stage_id"], name: "index_application_submissions_on_application_stage_id", using: :btree
    t.index ["batch_application_id"], name: "index_application_submissions_on_batch_application_id", using: :btree
  end

  create_table "batch_applicants", force: :cascade do |t|
    t.string   "name"
    t.string   "gender"
    t.string   "email"
    t.string   "phone"
    t.string   "role"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.string   "token"
    t.datetime "sign_in_email_sent_at"
    t.string   "reference",             default: "Other"
    t.text     "notes"
    t.datetime "last_sign_in_at"
    t.datetime "latest_payment_at"
    t.integer  "college_id"
    t.string   "college_text"
    t.string   "fee_payment_method"
    t.date     "born_on"
    t.string   "parent_name"
    t.text     "current_address"
    t.text     "permanent_address"
    t.string   "id_proof_number"
    t.string   "id_proof"
    t.string   "address_proof"
    t.string   "id_proof_type"
    t.string   "income_proof"
    t.string   "letter_from_parent"
    t.string   "college_contact"
    t.integer  "founder_id"
    t.index ["college_id"], name: "index_batch_applicants_on_college_id", using: :btree
    t.index ["founder_id"], name: "index_batch_applicants_on_founder_id", using: :btree
    t.index ["token"], name: "index_batch_applicants_on_token", using: :btree
  end

  create_table "batch_applicants_applications", id: false, force: :cascade do |t|
    t.integer "batch_applicant_id",   null: false
    t.integer "batch_application_id", null: false
    t.index ["batch_applicant_id", "batch_application_id"], name: "idx_applicants_applications_on_applicant_id_and_application_id", using: :btree
    t.index ["batch_application_id", "batch_applicant_id"], name: "idx_applications_applicants_on_application_id_and_applicant_id", using: :btree
  end

  create_table "batch_applications", force: :cascade do |t|
    t.integer  "batch_id"
    t.integer  "application_stage_id"
    t.integer  "university_id"
    t.text     "team_achievement"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.integer  "team_lead_id"
    t.string   "college_text"
    t.string   "state"
    t.integer  "team_size",            default: 2
    t.datetime "swept_at"
    t.datetime "swept_in_at"
    t.boolean  "agreements_verified",  default: false
    t.string   "courier_name"
    t.string   "courier_number"
    t.string   "partnership_deed"
    t.string   "payment_reference"
    t.integer  "startup_id"
    t.index ["application_stage_id"], name: "index_batch_applications_on_application_stage_id", using: :btree
    t.index ["batch_id"], name: "index_batch_applications_on_batch_id", using: :btree
    t.index ["startup_id"], name: "index_batch_applications_on_startup_id", using: :btree
    t.index ["team_lead_id"], name: "index_batch_applications_on_team_lead_id", using: :btree
    t.index ["university_id"], name: "index_batch_applications_on_university_id", using: :btree
  end

  create_table "batch_stages", force: :cascade do |t|
    t.integer  "batch_id"
    t.integer  "application_stage_id"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.index ["application_stage_id"], name: "index_batch_stages_on_application_stage_id", using: :btree
    t.index ["batch_id"], name: "index_batch_stages_on_batch_id", using: :btree
  end

  create_table "batches", force: :cascade do |t|
    t.string   "theme"
    t.text     "description"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.integer  "batch_number"
    t.string   "slack_channel"
    t.datetime "invites_sent_at"
    t.datetime "campaign_start_at"
    t.integer  "target_application_count"
  end

  create_table "colleges", force: :cascade do |t|
    t.string  "name"
    t.string  "also_known_as"
    t.string  "city"
    t.integer "state_id"
    t.string  "established_year"
    t.string  "website"
    t.string  "contact_numbers"
    t.integer "replacement_university_id"
    t.index ["replacement_university_id"], name: "index_colleges_on_replacement_university_id", using: :btree
    t.index ["state_id"], name: "index_colleges_on_state_id", using: :btree
  end

  create_table "connect_requests", force: :cascade do |t|
    t.integer  "connect_slot_id"
    t.integer  "startup_id"
    t.text     "questions"
    t.string   "status"
    t.string   "meeting_link"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.datetime "confirmed_at"
    t.datetime "feedback_mails_sent_at"
    t.integer  "rating_of_faculty"
    t.integer  "rating_of_team"
    t.index ["connect_slot_id"], name: "index_connect_requests_on_connect_slot_id", using: :btree
    t.index ["startup_id"], name: "index_connect_requests_on_startup_id", using: :btree
  end

  create_table "connect_slots", force: :cascade do |t|
    t.integer  "faculty_id"
    t.datetime "slot_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["faculty_id"], name: "index_connect_slots_on_faculty_id", using: :btree
  end

  create_table "course_modules", force: :cascade do |t|
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "name"
    t.integer  "module_number"
    t.string   "slug"
    t.datetime "publish_at"
    t.index ["slug"], name: "index_course_modules_on_slug", using: :btree
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
    t.index ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree
  end

  create_table "faculty", force: :cascade do |t|
    t.string   "name"
    t.string   "title"
    t.string   "key_skills"
    t.string   "linkedin_url"
    t.string   "category"
    t.string   "image"
    t.integer  "sort_index"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.string   "email"
    t.string   "token"
    t.boolean  "self_service"
    t.string   "current_commitment"
    t.string   "slug"
    t.integer  "founder_id"
    t.boolean  "inactive",           default: false
    t.text     "about"
    t.string   "commitment"
    t.string   "compensation"
    t.string   "slack_username"
    t.string   "slack_user_id"
    t.index ["category"], name: "index_faculty_on_category", using: :btree
    t.index ["slug"], name: "index_faculty_on_slug", unique: true, using: :btree
  end

  create_table "features", force: :cascade do |t|
    t.string   "key"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "founders", force: :cascade do |t|
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "avatar"
    t.string   "encrypted_password",        default: ""
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",             default: 0,     null: false
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
    t.string   "linkedin_url"
    t.string   "twitter_url"
    t.date     "born_on"
    t.string   "auth_token"
    t.string   "course"
    t.string   "semester"
    t.string   "gender"
    t.string   "phone"
    t.text     "communication_address"
    t.string   "phone_verification_code"
    t.boolean  "startup_admin"
    t.integer  "year_of_graduation"
    t.string   "roll_number"
    t.string   "slack_username"
    t.integer  "university_id"
    t.string   "unconfirmed_phone"
    t.string   "roles"
    t.string   "college_identification"
    t.boolean  "avatar_processing",         default: false
    t.string   "slack_user_id"
    t.string   "personal_website_url"
    t.string   "blog_url"
    t.string   "facebook_url"
    t.string   "angel_co_url"
    t.string   "github_url"
    t.string   "behance_url"
    t.string   "resume_url"
    t.string   "slug"
    t.string   "about"
    t.datetime "verification_code_sent_at"
    t.integer  "invited_batch_id"
    t.boolean  "timeline_toured"
    t.string   "identification_proof"
    t.string   "skype_id"
    t.string   "startup_token"
    t.boolean  "exited",                    default: false
    t.integer  "user_id"
    t.integer  "college_id"
    t.string   "name"
    t.index ["college_id"], name: "index_founders_on_college_id", using: :btree
    t.index ["confirmation_token"], name: "index_founders_on_confirmation_token", unique: true, using: :btree
    t.index ["invitation_token"], name: "index_founders_on_invitation_token", unique: true, using: :btree
    t.index ["invited_batch_id"], name: "index_founders_on_invited_batch_id", using: :btree
    t.index ["invited_by_id"], name: "index_founders_on_invited_by_id", using: :btree
    t.index ["name"], name: "index_founders_on_name", using: :btree
    t.index ["reset_password_token"], name: "index_founders_on_reset_password_token", unique: true, using: :btree
    t.index ["slug"], name: "index_founders_on_slug", unique: true, using: :btree
    t.index ["startup_token"], name: "index_founders_on_startup_token", using: :btree
    t.index ["university_id"], name: "index_founders_on_university_id", using: :btree
    t.index ["user_id"], name: "index_founders_on_user_id", using: :btree
  end

  create_table "glossary_terms", force: :cascade do |t|
    t.string   "term"
    t.text     "definition"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "karma_points", force: :cascade do |t|
    t.integer  "founder_id"
    t.integer  "points"
    t.string   "activity_type"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "source_id"
    t.string   "source_type"
    t.integer  "startup_id"
    t.index ["founder_id"], name: "index_karma_points_on_founder_id", using: :btree
    t.index ["source_id"], name: "index_karma_points_on_source_id", using: :btree
    t.index ["startup_id"], name: "index_karma_points_on_startup_id", using: :btree
  end

  create_table "module_chapters", force: :cascade do |t|
    t.integer  "course_module_id"
    t.string   "name"
    t.integer  "chapter_number"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.text     "links"
    t.string   "slug"
    t.index ["course_module_id"], name: "index_module_chapters_on_course_module_id", using: :btree
    t.index ["slug"], name: "index_module_chapters_on_slug", using: :btree
  end

  create_table "mooc_students", force: :cascade do |t|
    t.string   "email"
    t.string   "name"
    t.integer  "university_id"
    t.string   "college"
    t.string   "semester"
    t.string   "state"
    t.string   "gender"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "user_id"
    t.string   "phone"
    t.text     "completed_chapters"
  end

  create_table "payments", force: :cascade do |t|
    t.integer  "batch_application_id"
    t.string   "instamojo_payment_request_id"
    t.string   "instamojo_payment_request_status"
    t.string   "instamojo_payment_id"
    t.string   "instamojo_payment_status"
    t.decimal  "amount",                           precision: 9, scale: 2
    t.decimal  "fees",                             precision: 9, scale: 2
    t.string   "short_url"
    t.string   "long_url"
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
    t.datetime "webhook_received_at"
    t.datetime "paid_at"
    t.integer  "original_batch_application_id"
    t.integer  "batch_applicant_id"
    t.string   "notes"
    t.boolean  "refunded"
    t.index ["batch_applicant_id"], name: "index_payments_on_batch_applicant_id", using: :btree
    t.index ["batch_application_id"], name: "index_payments_on_batch_application_id", using: :btree
    t.index ["original_batch_application_id"], name: "index_payments_on_original_batch_application_id", using: :btree
  end

  create_table "platform_feedback", force: :cascade do |t|
    t.string   "feedback_type"
    t.string   "attachment"
    t.text     "description"
    t.integer  "promoter_score"
    t.integer  "founder_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "notes"
    t.index ["founder_id"], name: "index_platform_feedback_on_founder_id", using: :btree
  end

  create_table "program_weeks", force: :cascade do |t|
    t.string   "name"
    t.integer  "number"
    t.string   "icon"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "batch_id"
    t.index ["batch_id"], name: "index_program_weeks_on_batch_id", using: :btree
  end

  create_table "prospective_applicants", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.string   "phone"
    t.integer  "college_id"
    t.string   "college_text"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["college_id"], name: "index_prospective_applicants_on_college_id", using: :btree
  end

  create_table "public_slack_messages", force: :cascade do |t|
    t.text     "body"
    t.string   "slack_username"
    t.integer  "founder_id"
    t.string   "channel"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.string   "timestamp"
    t.integer  "reaction_to_id"
    t.index ["founder_id"], name: "index_public_slack_messages_on_founder_id", using: :btree
  end

  create_table "quiz_attempts", force: :cascade do |t|
    t.integer  "course_module_id"
    t.integer  "mooc_student_id"
    t.datetime "taken_at"
    t.float    "score"
    t.integer  "total_questions"
    t.integer  "attempted_questions"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.index ["course_module_id"], name: "index_quiz_attempts_on_course_module_id", using: :btree
    t.index ["mooc_student_id"], name: "index_quiz_attempts_on_mooc_student_id", using: :btree
  end

  create_table "quiz_questions", force: :cascade do |t|
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.integer  "course_module_id"
    t.text     "question"
    t.index ["course_module_id"], name: "index_quiz_questions_on_course_module_id", using: :btree
  end

  create_table "replacement_universities", force: :cascade do |t|
    t.string   "name"
    t.integer  "state_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["state_id"], name: "index_replacement_universities_on_state_id", using: :btree
  end

  create_table "resources", force: :cascade do |t|
    t.string   "file"
    t.string   "thumbnail"
    t.string   "title"
    t.text     "description"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "share_status"
    t.integer  "downloads",    default: 0
    t.string   "slug"
    t.integer  "batch_id"
    t.integer  "startup_id"
    t.index ["batch_id"], name: "index_resources_on_batch_id", using: :btree
    t.index ["share_status", "batch_id"], name: "index_resources_on_share_status_and_batch_id", using: :btree
    t.index ["slug"], name: "index_resources_on_slug", using: :btree
    t.index ["startup_id"], name: "index_resources_on_startup_id", using: :btree
  end

  create_table "shortened_urls", force: :cascade do |t|
    t.integer  "owner_id"
    t.string   "owner_type", limit: 20
    t.text     "url",                               null: false
    t.string   "unique_key", limit: 10,             null: false
    t.integer  "use_count",             default: 0, null: false
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["owner_id", "owner_type"], name: "index_shortened_urls_on_owner_id_and_owner_type", using: :btree
    t.index ["unique_key"], name: "index_shortened_urls_on_unique_key", unique: true, using: :btree
    t.index ["url"], name: "index_shortened_urls_on_url", using: :btree
  end

  create_table "startup_categories", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "startup_categories_startups", id: false, force: :cascade do |t|
    t.integer "startup_id"
    t.integer "startup_category_id"
  end

  create_table "startup_feedback", force: :cascade do |t|
    t.text     "feedback"
    t.string   "reference_url"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "startup_id"
    t.datetime "sent_at"
    t.integer  "faculty_id"
    t.string   "activity_type"
    t.string   "attachment"
    t.index ["faculty_id"], name: "index_startup_feedback_on_faculty_id", using: :btree
  end

  create_table "startups", force: :cascade do |t|
    t.string   "logo"
    t.string   "pitch"
    t.string   "website"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "facebook_link"
    t.string   "twitter_link"
    t.text     "address"
    t.string   "registration_type"
    t.string   "product_name"
    t.text     "product_description"
    t.string   "state"
    t.string   "district"
    t.string   "product_progress"
    t.string   "presentation_link"
    t.string   "pin"
    t.datetime "agreement_signed_at"
    t.text     "metadata"
    t.string   "slug"
    t.string   "stage"
    t.string   "legal_registered_name"
    t.string   "wireframe_link"
    t.string   "prototype_link"
    t.string   "product_video_link"
    t.integer  "batch_id"
    t.boolean  "dropped_out",           default: false
    t.index ["batch_id"], name: "index_startups_on_batch_id", using: :btree
    t.index ["slug"], name: "index_startups_on_slug", unique: true, using: :btree
    t.index ["stage"], name: "index_startups_on_stage", using: :btree
  end

  create_table "states", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       limit: 128
    t.datetime "created_at"
    t.index ["context"], name: "index_taggings_on_context", using: :btree
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
    t.index ["tag_id"], name: "index_taggings_on_tag_id", using: :btree
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy", using: :btree
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id", using: :btree
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type", using: :btree
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type", using: :btree
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id", using: :btree
  end

  create_table "tags", force: :cascade do |t|
    t.string  "name"
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true, using: :btree
  end

  create_table "target_groups", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "program_week_id"
    t.integer  "number"
    t.index ["number"], name: "index_target_groups_on_number", using: :btree
    t.index ["program_week_id"], name: "index_target_groups_on_program_week_id", using: :btree
  end

  create_table "target_prerequisites", force: :cascade do |t|
    t.integer "target_id"
    t.integer "prerequisite_target_id"
    t.index ["prerequisite_target_id"], name: "index_target_prerequisites_on_prerequisite_target_id", using: :btree
    t.index ["target_id"], name: "index_target_prerequisites_on_target_id", using: :btree
  end

  create_table "targets", force: :cascade do |t|
    t.string   "role"
    t.string   "title"
    t.text     "description"
    t.string   "completion_instructions"
    t.string   "resource_url"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.text     "slideshow_embed"
    t.integer  "assigner_id"
    t.string   "rubric"
    t.text     "review_test_embed"
    t.integer  "timeline_event_type_id"
    t.integer  "assignee_id"
    t.string   "assignee_type"
    t.integer  "days_to_complete"
    t.string   "target_type"
    t.integer  "target_group_id"
    t.integer  "batch_id"
    t.index ["assignee_id"], name: "index_targets_on_assignee_id", using: :btree
    t.index ["assignee_type"], name: "index_targets_on_assignee_type", using: :btree
    t.index ["batch_id"], name: "index_targets_on_batch_id", using: :btree
    t.index ["timeline_event_type_id"], name: "index_targets_on_timeline_event_type_id", using: :btree
  end

  create_table "team_members", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.string   "roles"
    t.string   "avatar"
    t.integer  "startup_id"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.boolean  "avatar_processing", default: false
    t.index ["startup_id"], name: "index_team_members_on_startup_id", using: :btree
  end

  create_table "timeline_event_files", force: :cascade do |t|
    t.integer  "timeline_event_id"
    t.string   "file"
    t.boolean  "private"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "title"
    t.index ["timeline_event_id"], name: "index_timeline_event_files_on_timeline_event_id", using: :btree
  end

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
    t.boolean  "major"
    t.index ["role"], name: "index_timeline_event_types_on_role", using: :btree
  end

  create_table "timeline_events", force: :cascade do |t|
    t.text     "description"
    t.string   "image"
    t.integer  "startup_id"
    t.text     "links"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.date     "event_on"
    t.datetime "verified_at"
    t.integer  "timeline_event_type_id"
    t.string   "verified_status"
    t.string   "grade"
    t.integer  "founder_id"
    t.integer  "improved_timeline_event_id"
    t.integer  "target_id"
    t.index ["founder_id"], name: "index_timeline_events_on_founder_id", using: :btree
    t.index ["startup_id"], name: "index_timeline_events_on_startup_id", using: :btree
    t.index ["timeline_event_type_id"], name: "index_timeline_events_on_timeline_event_type_id", using: :btree
  end

  create_table "universities", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "location"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email"
    t.string   "login_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",       default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "encrypted_password",  default: "", null: false
    t.string   "remember_token"
  end

  create_table "visits", id: :uuid, default: nil, force: :cascade do |t|
    t.uuid     "visitor_id"
    t.string   "ip"
    t.text     "user_agent"
    t.text     "referrer"
    t.text     "landing_page"
    t.integer  "user_id"
    t.string   "user_type"
    t.string   "referring_domain"
    t.string   "search_keyword"
    t.string   "browser"
    t.string   "os"
    t.string   "device_type"
    t.integer  "screen_height"
    t.integer  "screen_width"
    t.string   "country"
    t.string   "region"
    t.string   "city"
    t.string   "postal_code"
    t.decimal  "latitude"
    t.decimal  "longitude"
    t.string   "utm_source"
    t.string   "utm_medium"
    t.string   "utm_term"
    t.string   "utm_content"
    t.string   "utm_campaign"
    t.datetime "started_at"
    t.index ["user_id", "user_type"], name: "index_visits_on_user_id_and_user_type", using: :btree
  end

  add_foreign_key "batch_applicants", "founders"
  add_foreign_key "batch_applications", "startups"
  add_foreign_key "connect_requests", "connect_slots"
  add_foreign_key "connect_requests", "startups"
  add_foreign_key "connect_slots", "faculty"
  add_foreign_key "founders", "colleges"
  add_foreign_key "founders", "users"
  add_foreign_key "payments", "batch_applications"
  add_foreign_key "resources", "batches"
  add_foreign_key "startup_feedback", "faculty"
  add_foreign_key "team_members", "startups"
  add_foreign_key "timeline_event_files", "timeline_events"
  add_foreign_key "timeline_events", "startups"
end
