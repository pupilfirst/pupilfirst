# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_11_23_190246) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "pg_stat_statements"
  enable_extension "pg_trgm"
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "admin_users", id: :serial, force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "username"
    t.string "fullname"
    t.integer "user_id"
    t.string "email"
    t.index ["user_id"], name: "index_admin_users_on_user_id"
  end

  create_table "answer_options", force: :cascade do |t|
    t.bigint "quiz_question_id"
    t.text "value"
    t.text "hint"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["quiz_question_id"], name: "index_answer_options_on_quiz_question_id"
  end

  create_table "applicants", force: :cascade do |t|
    t.string "email"
    t.string "name"
    t.string "login_token"
    t.datetime "login_mail_sent_at"
    t.bigint "course_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_applicants_on_course_id"
    t.index ["email", "course_id"], name: "index_applicants_on_email_and_course_id", unique: true
    t.index ["login_token"], name: "index_applicants_on_login_token", unique: true
  end

  create_table "audit_records", force: :cascade do |t|
    t.bigint "school_id", null: false
    t.string "audit_type", null: false
    t.jsonb "metadata", default: {}
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["school_id"], name: "index_audit_records_on_school_id"
  end

  create_table "bounce_reports", force: :cascade do |t|
    t.citext "email", null: false
    t.string "bounce_type", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_bounce_reports_on_email", unique: true
  end

  create_table "certificates", force: :cascade do |t|
    t.bigint "course_id", null: false
    t.string "qr_corner", null: false
    t.integer "qr_scale", null: false
    t.integer "name_offset_top", null: false
    t.integer "font_size", null: false
    t.integer "margin", null: false
    t.boolean "active", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "name", null: false
    t.index ["course_id"], name: "index_certificates_on_course_id"
  end

  create_table "coach_notes", force: :cascade do |t|
    t.bigint "author_id"
    t.bigint "student_id"
    t.text "note"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "archived_at"
    t.index ["archived_at"], name: "index_coach_notes_on_archived_at"
    t.index ["author_id"], name: "index_coach_notes_on_author_id"
    t.index ["student_id"], name: "index_coach_notes_on_student_id"
  end

  create_table "communities", force: :cascade do |t|
    t.string "name"
    t.boolean "target_linkable", default: false
    t.bigint "school_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["school_id"], name: "index_communities_on_school_id"
  end

  create_table "community_course_connections", force: :cascade do |t|
    t.bigint "community_id"
    t.bigint "course_id"
    t.index ["community_id"], name: "index_community_course_connections_on_community_id"
    t.index ["course_id", "community_id"], name: "index_community_course_connection_on_course_id_and_community_id", unique: true
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

  create_table "content_blocks", force: :cascade do |t|
    t.string "block_type"
    t.json "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "sort_index", default: 0, null: false
    t.bigint "target_version_id"
    t.index ["block_type"], name: "index_content_blocks_on_block_type"
    t.index ["target_version_id"], name: "index_content_blocks_on_target_version_id"
  end

  create_table "course_authors", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "course_id"
    t.boolean "exited"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_course_authors_on_course_id"
    t.index ["user_id"], name: "index_course_authors_on_user_id"
  end

  create_table "course_exports", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "course_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "reviewed_only", default: false
    t.text "json_data"
    t.string "export_type"
    t.index ["course_id"], name: "index_course_exports_on_course_id"
    t.index ["user_id"], name: "index_course_exports_on_user_id"
  end

  create_table "courses", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "school_id"
    t.datetime "ends_at"
    t.string "description"
    t.boolean "enable_leaderboard", default: false
    t.boolean "public_signup", default: false
    t.text "about"
    t.boolean "featured", default: true
    t.boolean "can_connect", default: true
    t.string "progression_behavior", null: false
    t.integer "progression_limit"
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
    t.boolean "primary", default: false
    t.index ["fqdn"], name: "index_domains_on_fqdn", unique: true
    t.index ["school_id"], name: "index_domains_on_school_id"
  end

  create_table "evaluation_criteria", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.bigint "course_id"
    t.integer "max_grade"
    t.integer "pass_grade"
    t.jsonb "grade_labels"
    t.index ["course_id"], name: "index_evaluation_criteria_on_course_id"
  end

  create_table "faculty", id: :serial, force: :cascade do |t|
    t.string "category"
    t.integer "sort_index"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "token"
    t.string "current_commitment"
    t.string "commitment"
    t.string "compensation"
    t.string "slack_username"
    t.string "slack_user_id"
    t.bigint "user_id"
    t.boolean "public", default: false
    t.string "connect_link"
    t.boolean "notify_for_submission", default: false
    t.boolean "exited", default: false
    t.index ["category"], name: "index_faculty_on_category"
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
    t.integer "startup_id"
    t.string "auth_token"
    t.string "slack_username"
    t.string "roles"
    t.string "slack_user_id"
    t.integer "user_id"
    t.boolean "dashboard_toured"
    t.integer "resume_file_id"
    t.string "slack_access_token"
    t.boolean "excluded_from_leaderboard", default: false
    t.index ["user_id"], name: "index_founders_on_user_id"
  end

  create_table "issued_certificates", force: :cascade do |t|
    t.bigint "certificate_id", null: false
    t.bigint "user_id"
    t.string "name", null: false
    t.citext "serial_number", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "issuer_id"
    t.bigint "revoker_id"
    t.datetime "revoked_at"
    t.index ["certificate_id"], name: "index_issued_certificates_on_certificate_id"
    t.index ["issuer_id"], name: "index_issued_certificates_on_issuer_id"
    t.index ["revoker_id"], name: "index_issued_certificates_on_revoker_id"
    t.index ["serial_number"], name: "index_issued_certificates_on_serial_number", unique: true
    t.index ["user_id"], name: "index_issued_certificates_on_user_id"
  end

  create_table "leaderboard_entries", force: :cascade do |t|
    t.bigint "founder_id"
    t.datetime "period_from", null: false
    t.datetime "period_to", null: false
    t.integer "score", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["founder_id", "period_from", "period_to"], name: "index_leaderboard_entries_on_founder_id_and_period", unique: true
    t.index ["founder_id"], name: "index_leaderboard_entries_on_founder_id"
  end

  create_table "levels", id: :serial, force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "unlock_at"
    t.bigint "course_id"
    t.index ["course_id"], name: "index_levels_on_course_id"
    t.index ["number", "course_id"], name: "index_levels_on_number_and_course_id", unique: true
  end

  create_table "markdown_attachments", force: :cascade do |t|
    t.string "token"
    t.datetime "last_accessed_at"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "school_id"
    t.index ["school_id"], name: "index_markdown_attachments_on_school_id"
    t.index ["user_id"], name: "index_markdown_attachments_on_user_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "actor_id"
    t.bigint "recipient_id"
    t.string "notifiable_type"
    t.bigint "notifiable_id"
    t.datetime "read_at"
    t.text "message"
    t.string "event"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["actor_id"], name: "index_notifications_on_actor_id"
    t.index ["notifiable_type", "notifiable_id"], name: "index_notifications_on_notifiable_type_and_notifiable_id"
    t.index ["recipient_id"], name: "index_notifications_on_recipient_id"
  end

  create_table "post_likes", force: :cascade do |t|
    t.bigint "post_id"
    t.bigint "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["post_id", "user_id"], name: "index_post_likes_on_post_id_and_user_id", unique: true
    t.index ["user_id"], name: "index_post_likes_on_user_id"
  end

  create_table "posts", force: :cascade do |t|
    t.bigint "topic_id"
    t.bigint "creator_id"
    t.bigint "editor_id"
    t.bigint "archiver_id"
    t.datetime "archived_at"
    t.bigint "reply_to_post_id"
    t.integer "post_number", null: false
    t.text "body"
    t.boolean "solution", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "edit_reason"
    t.index ["archiver_id"], name: "index_posts_on_archiver_id"
    t.index ["creator_id"], name: "index_posts_on_creator_id"
    t.index ["editor_id"], name: "index_posts_on_editor_id"
    t.index ["post_number", "topic_id"], name: "index_posts_on_post_number_and_topic_id", unique: true
    t.index ["reply_to_post_id"], name: "index_posts_on_reply_to_post_id"
    t.index ["topic_id"], name: "index_posts_on_topic_id"
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
    t.text "question"
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

  create_table "resource_versions", force: :cascade do |t|
    t.jsonb "value"
    t.string "versionable_type"
    t.bigint "versionable_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["versionable_type", "versionable_id"], name: "index_resource_versions_on_versionable_type_and_versionable_id"
  end

  create_table "school_admins", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "school_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["school_id"], name: "index_school_admins_on_school_id"
    t.index ["user_id", "school_id"], name: "index_school_admins_on_user_id_and_school_id", unique: true
    t.index ["user_id"], name: "index_school_admins_on_user_id"
  end

  create_table "school_links", force: :cascade do |t|
    t.bigint "school_id"
    t.string "title"
    t.string "url"
    t.string "kind"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["school_id", "kind"], name: "index_school_links_on_school_id_and_kind"
  end

  create_table "school_strings", force: :cascade do |t|
    t.bigint "school_id"
    t.string "key"
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["school_id", "key"], name: "index_school_strings_on_school_id_and_key", unique: true
  end

  create_table "schools", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "about"
    t.jsonb "configuration", default: {}, null: false
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

  create_table "startups", id: :serial, force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "name"
    t.integer "level_id"
    t.datetime "access_ends_at"
    t.datetime "dropped_out_at"
    t.index ["level_id"], name: "index_startups_on_level_id"
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
    t.boolean "archived", default: false
    t.index ["level_id"], name: "index_target_groups_on_level_id"
    t.index ["sort_index"], name: "index_target_groups_on_sort_index"
  end

  create_table "target_prerequisites", id: :serial, force: :cascade do |t|
    t.integer "target_id"
    t.integer "prerequisite_target_id"
    t.index ["prerequisite_target_id"], name: "index_target_prerequisites_on_prerequisite_target_id"
    t.index ["target_id"], name: "index_target_prerequisites_on_target_id"
  end

  create_table "target_versions", force: :cascade do |t|
    t.bigint "target_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["target_id"], name: "index_target_versions_on_target_id"
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
    t.integer "days_to_complete"
    t.string "target_action_type"
    t.integer "target_group_id"
    t.integer "sort_index", default: 999
    t.datetime "session_at"
    t.text "video_embed"
    t.datetime "last_session_at"
    t.string "link_to_complete"
    t.boolean "archived", default: false
    t.string "youtube_video_id"
    t.datetime "feedback_asked_at"
    t.datetime "slack_reminders_sent_at"
    t.string "call_to_action"
    t.text "rubric_description"
    t.boolean "resubmittable", default: true
    t.string "visibility"
    t.jsonb "review_checklist", default: []
    t.jsonb "checklist", default: []
    t.index ["archived"], name: "index_targets_on_archived"
    t.index ["faculty_id"], name: "index_targets_on_faculty_id"
    t.index ["session_at"], name: "index_targets_on_session_at"
  end

  create_table "text_versions", force: :cascade do |t|
    t.text "value"
    t.string "versionable_type"
    t.bigint "versionable_id"
    t.bigint "user_id"
    t.datetime "edited_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "reason"
    t.index ["user_id"], name: "index_text_versions_on_user_id"
    t.index ["versionable_type", "versionable_id"], name: "index_text_versions_on_versionable_type_and_versionable_id"
  end

  create_table "timeline_event_files", id: :serial, force: :cascade do |t|
    t.integer "timeline_event_id"
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
    t.boolean "latest", default: false
    t.index ["founder_id"], name: "index_timeline_event_owners_on_founder_id"
    t.index ["timeline_event_id"], name: "index_timeline_event_owners_on_timeline_event_id"
  end

  create_table "timeline_events", id: :serial, force: :cascade do |t|
    t.string "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "target_id"
    t.decimal "score", precision: 2, scale: 1
    t.integer "evaluator_id"
    t.datetime "passed_at"
    t.string "quiz_score"
    t.datetime "evaluated_at"
    t.jsonb "checklist", default: []
  end

  create_table "topic_categories", force: :cascade do |t|
    t.bigint "community_id", null: false
    t.string "name", null: false
    t.index ["community_id"], name: "index_topic_categories_on_community_id"
    t.index ["name", "community_id"], name: "index_topic_categories_on_name_and_community_id", unique: true
  end

  create_table "topic_subscriptions", force: :cascade do |t|
    t.bigint "topic_id"
    t.bigint "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["topic_id", "user_id"], name: "index_topic_subscriptions_on_topic_id_and_user_id", unique: true
    t.index ["user_id"], name: "index_topic_subscriptions_on_user_id"
  end

  create_table "topics", force: :cascade do |t|
    t.bigint "community_id"
    t.bigint "target_id"
    t.datetime "last_activity_at"
    t.boolean "archived", default: false, null: false
    t.string "title"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "views", default: 0
    t.bigint "topic_category_id"
    t.datetime "locked_at"
    t.bigint "locked_by_id"
    t.index ["community_id"], name: "index_topics_on_community_id"
    t.index ["locked_by_id"], name: "index_topics_on_locked_by_id"
    t.index ["target_id"], name: "index_topics_on_target_id"
    t.index ["topic_category_id"], name: "index_topics_on_topic_category_id"
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
    t.datetime "confirmed_at"
    t.datetime "login_mail_sent_at"
    t.string "name"
    t.string "title"
    t.text "about"
    t.bigint "school_id"
    t.jsonb "preferences", default: {"daily_digest"=>true}, null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.string "affiliation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "time_zone", default: "Asia/Kolkata", null: false
    t.string "delete_account_token"
    t.datetime "delete_account_sent_at"
    t.datetime "account_deletion_notification_sent_at"
    t.string "api_token_digest"
    t.string "locale", default: "en"
    t.jsonb "webpush_subscription", default: {}
    t.index ["api_token_digest"], name: "index_users_on_api_token_digest", unique: true
    t.index ["delete_account_token"], name: "index_users_on_delete_account_token", unique: true
    t.index ["email", "school_id"], name: "index_users_on_email_and_school_id", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["school_id"], name: "index_users_on_school_id"
  end

  create_table "webhook_deliveries", force: :cascade do |t|
    t.string "event", null: false
    t.string "status"
    t.jsonb "response_headers"
    t.text "response_body"
    t.jsonb "payload", default: {}
    t.string "webhook_url", null: false
    t.datetime "sent_at"
    t.string "error_class"
    t.bigint "course_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["course_id"], name: "index_webhook_deliveries_on_course_id"
  end

  create_table "webhook_endpoints", force: :cascade do |t|
    t.bigint "course_id", null: false
    t.string "webhook_url", null: false
    t.boolean "active", default: true
    t.jsonb "events", array: true
    t.string "hmac_key", null: false
    t.index ["course_id"], name: "index_webhook_endpoints_on_course_id", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "admin_users", "users"
  add_foreign_key "answer_options", "quiz_questions"
  add_foreign_key "applicants", "courses"
  add_foreign_key "certificates", "courses"
  add_foreign_key "communities", "schools"
  add_foreign_key "community_course_connections", "communities"
  add_foreign_key "community_course_connections", "courses"
  add_foreign_key "connect_requests", "connect_slots"
  add_foreign_key "connect_requests", "startups"
  add_foreign_key "connect_slots", "faculty"
  add_foreign_key "course_authors", "courses"
  add_foreign_key "course_authors", "users"
  add_foreign_key "course_exports", "courses"
  add_foreign_key "course_exports", "users"
  add_foreign_key "courses", "schools"
  add_foreign_key "domains", "schools"
  add_foreign_key "faculty_course_enrollments", "courses"
  add_foreign_key "faculty_course_enrollments", "faculty"
  add_foreign_key "faculty_startup_enrollments", "faculty"
  add_foreign_key "faculty_startup_enrollments", "startups"
  add_foreign_key "founders", "users"
  add_foreign_key "issued_certificates", "certificates"
  add_foreign_key "issued_certificates", "users"
  add_foreign_key "issued_certificates", "users", column: "issuer_id"
  add_foreign_key "issued_certificates", "users", column: "revoker_id"
  add_foreign_key "leaderboard_entries", "founders"
  add_foreign_key "levels", "courses"
  add_foreign_key "markdown_attachments", "users"
  add_foreign_key "posts", "posts", column: "reply_to_post_id"
  add_foreign_key "posts", "topics"
  add_foreign_key "quiz_questions", "answer_options", column: "correct_answer_id"
  add_foreign_key "quiz_questions", "quizzes"
  add_foreign_key "quizzes", "targets"
  add_foreign_key "school_admins", "schools"
  add_foreign_key "school_admins", "users"
  add_foreign_key "school_links", "schools"
  add_foreign_key "school_strings", "schools"
  add_foreign_key "startup_feedback", "faculty"
  add_foreign_key "startup_feedback", "timeline_events"
  add_foreign_key "startups", "levels"
  add_foreign_key "target_evaluation_criteria", "evaluation_criteria"
  add_foreign_key "target_evaluation_criteria", "targets"
  add_foreign_key "target_groups", "levels"
  add_foreign_key "target_versions", "targets"
  add_foreign_key "timeline_event_files", "timeline_events"
  add_foreign_key "timeline_events", "faculty", column: "evaluator_id"
  add_foreign_key "topic_categories", "communities"
  add_foreign_key "topics", "communities"
  add_foreign_key "topics", "topic_categories"
  add_foreign_key "topics", "users", column: "locked_by_id"
  add_foreign_key "users", "schools"
  add_foreign_key "webhook_endpoints", "courses"
end
