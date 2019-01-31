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

ActiveRecord::Schema.define(version: 2019_01_31_094209) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_stat_statements"
  enable_extension "pg_trgm"
  enable_extension "plpgsql"

  create_table "active_admin_comments", id: :serial, force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type", null: false
    t.integer "author_id"
    t.string "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "resource_id", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "admin_users", id: :serial, force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "username"
    t.string "avatar"
    t.string "fullname"
    t.string "admin_type"
    t.integer "user_id"
    t.index ["user_id"], name: "index_admin_users_on_user_id"
  end

  create_table "ahoy_events", id: :uuid, default: nil, force: :cascade do |t|
    t.uuid "visit_id"
    t.integer "user_id"
    t.string "user_type"
    t.string "name"
    t.jsonb "properties"
    t.datetime "time"
    t.index ["time"], name: "index_ahoy_events_on_time"
    t.index ["user_id", "user_type"], name: "index_ahoy_events_on_user_id_and_user_type"
    t.index ["visit_id"], name: "index_ahoy_events_on_visit_id"
  end

  create_table "answer_options", force: :cascade do |t|
    t.bigint "quiz_question_id"
    t.string "value"
    t.text "hint"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["quiz_question_id"], name: "index_answer_options_on_quiz_question_id"
  end

  create_table "colleges", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "also_known_as"
    t.string "city"
    t.integer "state_id"
    t.string "established_year"
    t.string "website"
    t.string "contact_numbers"
    t.integer "university_id"
    t.index ["state_id"], name: "index_colleges_on_state_id"
    t.index ["university_id"], name: "index_colleges_on_university_id"
  end

  create_table "connect_requests", id: :serial, force: :cascade do |t|
    t.integer "connect_slot_id"
    t.integer "startup_id"
    t.text "questions"
    t.string "status"
    t.string "meeting_link"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "confirmed_at"
    t.datetime "feedback_mails_sent_at"
    t.integer "rating_for_faculty"
    t.integer "rating_for_team"
    t.text "comment_for_faculty"
    t.text "comment_for_team"
    t.index ["connect_slot_id"], name: "index_connect_requests_on_connect_slot_id"
    t.index ["startup_id"], name: "index_connect_requests_on_startup_id"
  end

  create_table "connect_slots", id: :serial, force: :cascade do |t|
    t.integer "faculty_id"
    t.datetime "slot_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["faculty_id"], name: "index_connect_slots_on_faculty_id"
  end

  create_table "coupon_usages", id: :serial, force: :cascade do |t|
    t.integer "coupon_id"
    t.integer "startup_id"
    t.datetime "redeemed_at"
    t.datetime "rewarded_at"
    t.text "notes"
    t.index ["coupon_id"], name: "index_coupon_usages_on_coupon_id"
    t.index ["startup_id"], name: "index_coupon_usages_on_startup_id"
  end

  create_table "coupons", id: :serial, force: :cascade do |t|
    t.string "code"
    t.integer "discount_percentage"
    t.integer "redeem_limit", default: 0
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "instructions"
  end

  create_table "courses", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "sponsored", default: false
    t.bigint "school_id"
    t.integer "max_grade"
    t.integer "pass_grade"
    t.json "grade_labels"
    t.datetime "ends_at"
    t.index ["school_id"], name: "index_courses_on_school_id"
  end

  create_table "data_migrations", id: false, force: :cascade do |t|
    t.string "version", null: false
    t.index ["version"], name: "unique_data_migrations", unique: true
  end

  create_table "delayed_jobs", id: :serial, force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "domains", force: :cascade do |t|
    t.bigint "school_id"
    t.string "fqdn"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["fqdn"], name: "index_domains_on_fqdn", unique: true
    t.index ["school_id"], name: "index_domains_on_school_id"
  end

  create_table "engineering_metrics", id: :serial, force: :cascade do |t|
    t.json "metrics", default: {}, null: false
    t.datetime "week_start_at"
  end

  create_table "evaluation_criteria", force: :cascade do |t|
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.bigint "course_id"
    t.index ["course_id"], name: "index_evaluation_criteria_on_course_id"
  end

  create_table "faculty", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "title"
    t.string "key_skills"
    t.string "linkedin_url"
    t.string "category"
    t.string "image"
    t.integer "sort_index"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "token"
    t.boolean "self_service"
    t.string "current_commitment"
    t.string "slug"
    t.boolean "inactive", default: false
    t.text "about"
    t.string "commitment"
    t.string "compensation"
    t.string "slack_username"
    t.string "slack_user_id"
    t.bigint "user_id"
    t.index ["category"], name: "index_faculty_on_category"
    t.index ["slug"], name: "index_faculty_on_slug", unique: true
    t.index ["user_id"], name: "index_faculty_on_user_id"
  end

  create_table "faculty_course_enrollments", force: :cascade do |t|
    t.bigint "faculty_id"
    t.bigint "course_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id", "faculty_id"], name: "index_faculty_course_enrollments_on_course_id_and_faculty_id", unique: true
    t.index ["faculty_id"], name: "index_faculty_course_enrollments_on_faculty_id"
  end

  create_table "faculty_startup_enrollments", force: :cascade do |t|
    t.bigint "faculty_id"
    t.bigint "startup_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["faculty_id"], name: "index_faculty_startup_enrollments_on_faculty_id"
    t.index ["startup_id", "faculty_id"], name: "index_faculty_startup_enrollments_on_startup_id_and_faculty_id", unique: true
  end

  create_table "features", id: :serial, force: :cascade do |t|
    t.string "key"
    t.string "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "founders", id: :serial, force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "avatar"
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.integer "invited_by_id"
    t.string "invited_by_type"
    t.integer "startup_id"
    t.string "linkedin_url"
    t.string "twitter_url"
    t.date "born_on"
    t.string "auth_token"
    t.string "college_course"
    t.string "semester"
    t.string "gender"
    t.string "phone"
    t.text "communication_address"
    t.integer "year_of_graduation"
    t.string "roll_number"
    t.string "slack_username"
    t.integer "university_id"
    t.string "roles"
    t.string "college_identification"
    t.boolean "avatar_processing", default: false
    t.string "slack_user_id"
    t.string "personal_website_url"
    t.string "blog_url"
    t.string "facebook_url"
    t.string "angel_co_url"
    t.string "github_url"
    t.string "behance_url"
    t.string "resume_url"
    t.string "slug"
    t.string "about"
    t.string "identification_proof"
    t.string "skype_id"
    t.boolean "exited", default: false
    t.integer "user_id"
    t.integer "college_id"
    t.string "name"
    t.boolean "dashboard_toured"
    t.integer "backlog"
    t.string "reference"
    t.string "college_text"
    t.string "parent_name"
    t.string "id_proof_type"
    t.string "id_proof_number"
    t.string "income_proof"
    t.string "letter_from_parent"
    t.string "college_contact"
    t.string "permanent_address"
    t.string "address_proof"
    t.integer "invited_startup_id"
    t.integer "resume_file_id"
    t.string "slack_access_token"
    t.jsonb "screening_data"
    t.boolean "coder"
    t.index "((screening_data -> 'score'::text))", name: "index_founders_on_screening_data_score", using: :gin
    t.index ["college_id"], name: "index_founders_on_college_id"
    t.index ["invitation_token"], name: "index_founders_on_invitation_token", unique: true
    t.index ["invited_by_id"], name: "index_founders_on_invited_by_id"
    t.index ["invited_startup_id"], name: "index_founders_on_invited_startup_id"
    t.index ["name"], name: "index_founders_on_name"
    t.index ["slug"], name: "index_founders_on_slug", unique: true
    t.index ["university_id"], name: "index_founders_on_university_id"
    t.index ["user_id"], name: "index_founders_on_user_id"
  end

  create_table "karma_points", id: :serial, force: :cascade do |t|
    t.integer "founder_id"
    t.integer "points"
    t.string "activity_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "source_id"
    t.string "source_type"
    t.integer "startup_id"
    t.index ["founder_id"], name: "index_karma_points_on_founder_id"
    t.index ["source_id"], name: "index_karma_points_on_source_id"
    t.index ["startup_id"], name: "index_karma_points_on_startup_id"
  end

  create_table "levels", id: :serial, force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "unlock_on"
    t.bigint "course_id"
    t.index ["course_id"], name: "index_levels_on_course_id"
    t.index ["number"], name: "index_levels_on_number"
  end

  create_table "payments", id: :serial, force: :cascade do |t|
    t.string "instamojo_payment_request_id"
    t.string "instamojo_payment_request_status"
    t.string "instamojo_payment_id"
    t.string "instamojo_payment_status"
    t.decimal "amount", precision: 9, scale: 2
    t.decimal "fees", precision: 9, scale: 2
    t.string "short_url"
    t.string "long_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "webhook_received_at"
    t.datetime "paid_at"
    t.string "notes"
    t.integer "founder_id"
    t.integer "startup_id"
    t.integer "original_startup_id"
    t.datetime "billing_start_at"
    t.datetime "billing_end_at"
    t.string "payment_type"
    t.index ["founder_id"], name: "index_payments_on_founder_id"
    t.index ["original_startup_id"], name: "index_payments_on_original_startup_id"
    t.index ["startup_id"], name: "index_payments_on_startup_id"
  end

  create_table "platform_feedback", id: :serial, force: :cascade do |t|
    t.string "feedback_type"
    t.string "attachment"
    t.text "description"
    t.integer "promoter_score"
    t.integer "founder_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "notes"
    t.index ["founder_id"], name: "index_platform_feedback_on_founder_id"
  end

  create_table "product_metrics", force: :cascade do |t|
    t.string "category"
    t.integer "value"
    t.integer "delta_period"
    t.integer "delta_value"
    t.string "assignment_mode"
    t.bigint "faculty_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["faculty_id"], name: "index_product_metrics_on_faculty_id"
  end

  create_table "prospective_applicants", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "phone"
    t.integer "college_id"
    t.string "college_text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["college_id"], name: "index_prospective_applicants_on_college_id"
  end

  create_table "public_slack_messages", id: :serial, force: :cascade do |t|
    t.text "body"
    t.string "slack_username"
    t.integer "founder_id"
    t.string "channel"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "timestamp"
    t.integer "reaction_to_id"
    t.index ["founder_id"], name: "index_public_slack_messages_on_founder_id"
  end

  create_table "quiz_questions", force: :cascade do |t|
    t.string "question"
    t.text "description"
    t.bigint "quiz_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "correct_answer_id"
    t.index ["correct_answer_id"], name: "index_quiz_questions_on_correct_answer_id"
    t.index ["quiz_id"], name: "index_quiz_questions_on_quiz_id"
  end

  create_table "quizzes", force: :cascade do |t|
    t.string "title"
    t.bigint "target_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["target_id"], name: "index_quizzes_on_target_id"
  end

  create_table "resources", id: :serial, force: :cascade do |t|
    t.string "file"
    t.string "thumbnail"
    t.string "title"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "downloads", default: 0
    t.string "slug"
    t.integer "startup_id"
    t.text "video_embed"
    t.integer "level_id"
    t.string "link"
    t.string "file_content_type"
    t.boolean "archived", default: false
    t.bigint "course_id"
    t.boolean "public", default: false
    t.index ["archived"], name: "index_resources_on_archived"
    t.index ["course_id"], name: "index_resources_on_course_id"
    t.index ["level_id"], name: "index_resources_on_level_id"
    t.index ["slug"], name: "index_resources_on_slug"
    t.index ["startup_id"], name: "index_resources_on_startup_id"
  end

  create_table "schools", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "shortened_urls", id: :serial, force: :cascade do |t|
    t.integer "owner_id"
    t.string "owner_type", limit: 20
    t.text "url", null: false
    t.string "unique_key", limit: 100, null: false
    t.integer "use_count", default: 0, null: false
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["owner_id", "owner_type"], name: "index_shortened_urls_on_owner_id_and_owner_type"
    t.index ["unique_key"], name: "index_shortened_urls_on_unique_key", unique: true
    t.index ["url"], name: "index_shortened_urls_on_url"
  end

  create_table "startup_feedback", id: :serial, force: :cascade do |t|
    t.text "feedback"
    t.string "reference_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "startup_id"
    t.datetime "sent_at"
    t.integer "faculty_id"
    t.string "activity_type"
    t.string "attachment"
    t.integer "timeline_event_id"
    t.index ["faculty_id"], name: "index_startup_feedback_on_faculty_id"
    t.index ["timeline_event_id"], name: "index_startup_feedback_on_timeline_event_id"
  end

  create_table "startup_quotes", force: :cascade do |t|
    t.string "guid"
    t.string "link"
    t.integer "post_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["guid"], name: "index_startup_quotes_on_guid"
    t.index ["post_count"], name: "index_startup_quotes_on_post_count"
  end

  create_table "startups", id: :serial, force: :cascade do |t|
    t.string "logo"
    t.string "pitch"
    t.string "website"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "facebook_link"
    t.string "twitter_link"
    t.text "address"
    t.string "registration_type"
    t.string "product_name"
    t.text "product_description"
    t.string "state"
    t.string "district"
    t.string "product_progress"
    t.string "presentation_link"
    t.string "pin"
    t.text "metadata"
    t.string "slug"
    t.string "stage"
    t.string "legal_registered_name"
    t.string "wireframe_link"
    t.string "prototype_link"
    t.string "product_video_link"
    t.boolean "dropped_out", default: false
    t.integer "level_id"
    t.date "program_started_on"
    t.string "courier_name"
    t.string "courier_number"
    t.string "partnership_deed"
    t.string "payment_reference"
    t.string "admission_stage"
    t.date "timeline_updated_on"
    t.datetime "admission_stage_updated_at"
    t.integer "referral_reward_days", default: 0
    t.integer "undiscounted_founder_fee"
    t.text "billing_address"
    t.bigint "billing_state_id"
    t.bigint "faculty_id"
    t.index ["billing_state_id"], name: "index_startups_on_billing_state_id"
    t.index ["faculty_id"], name: "index_startups_on_faculty_id"
    t.index ["level_id"], name: "index_startups_on_level_id"
    t.index ["slug"], name: "index_startups_on_slug", unique: true
    t.index ["stage"], name: "index_startups_on_stage"
  end

  create_table "states", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "taggings", id: :serial, force: :cascade do |t|
    t.integer "tag_id"
    t.integer "taggable_id"
    t.string "taggable_type"
    t.integer "tagger_id"
    t.string "tagger_type"
    t.string "context", limit: 128
    t.datetime "created_at"
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
  end

  create_table "tags", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "target_evaluation_criteria", force: :cascade do |t|
    t.bigint "target_id"
    t.bigint "evaluation_criterion_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["evaluation_criterion_id"], name: "index_target_evaluation_criteria_on_evaluation_criterion_id"
    t.index ["target_id"], name: "index_target_evaluation_criteria_on_target_id"
  end

  create_table "target_groups", id: :serial, force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "sort_index"
    t.boolean "milestone"
    t.integer "level_id"
    t.bigint "track_id"
    t.boolean "archived", default: false
    t.index ["level_id"], name: "index_target_groups_on_level_id"
    t.index ["sort_index"], name: "index_target_groups_on_sort_index"
    t.index ["track_id"], name: "index_target_groups_on_track_id"
  end

  create_table "target_prerequisites", id: :serial, force: :cascade do |t|
    t.integer "target_id"
    t.integer "prerequisite_target_id"
    t.index ["prerequisite_target_id"], name: "index_target_prerequisites_on_prerequisite_target_id"
    t.index ["target_id"], name: "index_target_prerequisites_on_target_id"
  end

  create_table "target_resources", force: :cascade do |t|
    t.bigint "target_id", null: false
    t.bigint "resource_id", null: false
    t.index ["resource_id"], name: "index_target_resources_on_resource_id"
    t.index ["target_id", "resource_id"], name: "index_target_resources_on_target_id_and_resource_id", unique: true
  end

  create_table "targets", id: :serial, force: :cascade do |t|
    t.string "role"
    t.string "title"
    t.text "description"
    t.string "completion_instructions"
    t.string "resource_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "slideshow_embed"
    t.integer "faculty_id"
    t.string "rubric"
    t.integer "days_to_complete"
    t.string "target_action_type"
    t.integer "target_group_id"
    t.integer "points_earnable"
    t.integer "sort_index", default: 999
    t.datetime "session_at"
    t.text "video_embed"
    t.datetime "last_session_at"
    t.string "key"
    t.string "link_to_complete"
    t.boolean "archived", default: false
    t.string "youtube_video_id"
    t.string "google_calendar_event_id"
    t.datetime "feedback_asked_at"
    t.datetime "slack_reminders_sent_at"
    t.string "call_to_action"
    t.text "rubric_description"
    t.boolean "resubmittable", default: true
    t.index ["archived"], name: "index_targets_on_archived"
    t.index ["faculty_id"], name: "index_targets_on_faculty_id"
    t.index ["key"], name: "index_targets_on_key"
    t.index ["session_at"], name: "index_targets_on_session_at"
  end

  create_table "timeline_event_files", id: :serial, force: :cascade do |t|
    t.integer "timeline_event_id"
    t.string "file"
    t.boolean "private"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.index ["timeline_event_id"], name: "index_timeline_event_files_on_timeline_event_id"
  end

  create_table "timeline_event_grades", force: :cascade do |t|
    t.bigint "timeline_event_id"
    t.bigint "evaluation_criterion_id"
    t.integer "grade"
    t.index ["evaluation_criterion_id"], name: "index_timeline_event_grades_on_evaluation_criterion_id"
    t.index ["timeline_event_id", "evaluation_criterion_id"], name: "by_timeline_event_criterion", unique: true
    t.index ["timeline_event_id"], name: "index_timeline_event_grades_on_timeline_event_id"
  end

  create_table "timeline_event_owners", force: :cascade do |t|
    t.bigint "timeline_event_id"
    t.bigint "founder_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["founder_id"], name: "index_timeline_event_owners_on_founder_id"
    t.index ["timeline_event_id"], name: "index_timeline_event_owners_on_timeline_event_id"
  end

  create_table "timeline_events", id: :serial, force: :cascade do |t|
    t.text "description"
    t.string "image"
    t.text "links"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "event_on"
    t.integer "improved_timeline_event_id"
    t.integer "target_id"
    t.decimal "score", precision: 2, scale: 1
    t.integer "evaluator_id"
    t.datetime "passed_at"
    t.boolean "latest"
  end

  create_table "tracks", force: :cascade do |t|
    t.string "name"
    t.integer "sort_index", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "universities", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "state_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["state_id"], name: "index_universities_on_state_id"
  end

  create_table "user_activities", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "activity_type"
    t.json "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_activities_on_user_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email"
    t.string "login_token"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "encrypted_password", default: "", null: false
    t.string "remember_token"
    t.boolean "sign_out_at_next_request"
    t.datetime "email_bounced_at"
    t.string "email_bounce_type"
    t.datetime "confirmed_at"
    t.datetime "login_mail_sent_at"
  end

  create_table "visits", id: :uuid, default: nil, force: :cascade do |t|
    t.uuid "visitor_id"
    t.string "ip"
    t.text "user_agent"
    t.text "referrer"
    t.text "landing_page"
    t.integer "user_id"
    t.string "user_type"
    t.string "referring_domain"
    t.string "search_keyword"
    t.string "browser"
    t.string "os"
    t.string "device_type"
    t.integer "screen_height"
    t.integer "screen_width"
    t.string "country"
    t.string "region"
    t.string "city"
    t.string "postal_code"
    t.decimal "latitude"
    t.decimal "longitude"
    t.string "utm_source"
    t.string "utm_medium"
    t.string "utm_term"
    t.string "utm_content"
    t.string "utm_campaign"
    t.datetime "started_at"
    t.index ["user_id", "user_type"], name: "index_visits_on_user_id_and_user_type"
  end

  create_table "weekly_karma_points", id: :serial, force: :cascade do |t|
    t.datetime "week_starting_at"
    t.integer "startup_id"
    t.integer "level_id"
    t.integer "points"
    t.index ["level_id"], name: "index_weekly_karma_points_on_level_id"
    t.index ["startup_id"], name: "index_weekly_karma_points_on_startup_id"
    t.index ["week_starting_at", "level_id"], name: "index_weekly_karma_points_on_week_starting_at_and_level_id"
  end

  add_foreign_key "admin_users", "users"
  add_foreign_key "answer_options", "quiz_questions"
  add_foreign_key "connect_requests", "connect_slots"
  add_foreign_key "connect_requests", "startups"
  add_foreign_key "connect_slots", "faculty"
  add_foreign_key "courses", "schools"
  add_foreign_key "domains", "schools"
  add_foreign_key "faculty_course_enrollments", "courses"
  add_foreign_key "faculty_course_enrollments", "faculty"
  add_foreign_key "faculty_startup_enrollments", "faculty"
  add_foreign_key "faculty_startup_enrollments", "startups"
  add_foreign_key "founders", "colleges"
  add_foreign_key "founders", "users"
  add_foreign_key "levels", "courses"
  add_foreign_key "payments", "founders"
  add_foreign_key "payments", "startups"
  add_foreign_key "quiz_questions", "answer_options", column: "correct_answer_id"
  add_foreign_key "quiz_questions", "quizzes"
  add_foreign_key "quizzes", "targets"
  add_foreign_key "resources", "levels"
  add_foreign_key "startup_feedback", "faculty"
  add_foreign_key "startup_feedback", "timeline_events"
  add_foreign_key "startups", "levels"
  add_foreign_key "startups", "states", column: "billing_state_id"
  add_foreign_key "target_evaluation_criteria", "evaluation_criteria"
  add_foreign_key "target_evaluation_criteria", "targets"
  add_foreign_key "target_groups", "levels"
  add_foreign_key "target_groups", "tracks"
  add_foreign_key "target_resources", "resources"
  add_foreign_key "target_resources", "targets"
  add_foreign_key "timeline_event_files", "timeline_events"
  add_foreign_key "timeline_events", "faculty", column: "evaluator_id"
  add_foreign_key "user_activities", "users"
  add_foreign_key "weekly_karma_points", "levels"
  add_foreign_key "weekly_karma_points", "startups"
end
