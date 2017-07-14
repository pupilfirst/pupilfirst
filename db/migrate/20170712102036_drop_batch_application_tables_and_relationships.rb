class DropBatchApplicationTablesAndRelationships < ActiveRecord::Migration[5.1]
  def up
    drop_table :application_stages
    drop_table :application_submissions
    drop_table :application_submission_urls
    remove_column :payments, :batch_applicant_id
    drop_table :batch_applicants
    remove_column :payments, :original_batch_application_id
    remove_column :payments, :batch_application_id
    drop_table :batch_applications
    drop_table :batch_applicants_applications
    drop_table :round_stages
    drop_table :application_rounds
  end

  def down
    create_table 'application_rounds', id: :serial, force: :cascade do |t|
      t.integer 'batch_id'
      t.integer 'number'
      t.datetime 'campaign_start_at'
      t.integer 'target_application_count'
      t.datetime 'created_at', null: false
      t.datetime 'updated_at', null: false
      t.index ['batch_id'], name: 'index_application_rounds_on_batch_id'
    end

    create_table 'application_stages', id: :serial, force: :cascade do |t|
      t.string 'name'
      t.integer 'number'
      t.datetime 'created_at', null: false
      t.datetime 'updated_at', null: false
      t.boolean 'final_stage'
    end

    create_table 'application_submissions', id: :serial, force: :cascade do |t|
      t.integer 'application_stage_id'
      t.integer 'batch_application_id'
      t.integer 'score'
      t.datetime 'created_at', null: false
      t.datetime 'updated_at', null: false
      t.text 'notes'
      t.string 'file'
      t.text 'feedback_for_team'
      t.index ['application_stage_id'], name: 'index_application_submissions_on_application_stage_id'
      t.index ['batch_application_id'], name: 'index_application_submissions_on_batch_application_id'
    end

    create_table 'application_submission_urls', id: :serial, force: :cascade do |t|
      t.string 'name'
      t.string 'url'
      t.integer 'score'
      t.integer 'application_submission_id'
      t.datetime 'created_at', null: false
      t.datetime 'updated_at', null: false
      t.integer 'admin_user_id'
      t.index ['admin_user_id'], name: 'index_application_submission_urls_on_admin_user_id'
      t.index ['application_submission_id'], name: 'index_application_submission_urls_on_application_submission_id'
    end

    create_table 'batch_applicants', id: :serial, force: :cascade do |t|
      t.string 'name'
      t.string 'gender'
      t.string 'email'
      t.string 'phone'
      t.string 'role'
      t.datetime 'created_at', null: false
      t.datetime 'updated_at', null: false
      t.string 'reference', default: 'Other'
      t.text 'notes'
      t.datetime 'latest_payment_at'
      t.integer 'college_id'
      t.string 'college_text'
      t.string 'fee_payment_method'
      t.date 'born_on'
      t.string 'parent_name'
      t.text 'current_address'
      t.text 'permanent_address'
      t.string 'id_proof_number'
      t.string 'id_proof'
      t.string 'address_proof'
      t.string 'id_proof_type'
      t.string 'income_proof'
      t.string 'letter_from_parent'
      t.string 'college_contact'
      t.integer 'founder_id'
      t.integer 'user_id'
      t.index ['college_id'], name: 'index_batch_applicants_on_college_id'
      t.index ['founder_id'], name: 'index_batch_applicants_on_founder_id'
      t.index ['user_id'], name: 'index_batch_applicants_on_user_id'
    end

    create_table 'batch_applications', id: :serial, force: :cascade do |t|
      t.integer 'application_stage_id'
      t.integer 'university_id'
      t.text 'team_achievement'
      t.datetime 'created_at', null: false
      t.datetime 'updated_at', null: false
      t.integer 'team_lead_id'
      t.string 'college_text'
      t.string 'state'
      t.integer 'team_size', default: 2
      t.datetime 'swept_at'
      t.datetime 'swept_in_at'
      t.boolean 'agreements_verified', default: false
      t.string 'courier_name'
      t.string 'courier_number'
      t.string 'partnership_deed'
      t.string 'payment_reference'
      t.integer 'startup_id'
      t.integer 'application_round_id'
      t.boolean 'generate_certificate', default: false
      t.index ['application_round_id'], name: 'index_batch_applications_on_application_round_id'
      t.index ['application_stage_id'], name: 'index_batch_applications_on_application_stage_id'
      t.index ['startup_id'], name: 'index_batch_applications_on_startup_id'
      t.index ['team_lead_id'], name: 'index_batch_applications_on_team_lead_id'
      t.index ['university_id'], name: 'index_batch_applications_on_university_id'
    end

    create_table 'batch_applicants_applications', id: false, force: :cascade do |t|
      t.integer 'batch_applicant_id', null: false
      t.integer 'batch_application_id', null: false
      t.index %w(batch_applicant_id batch_application_id), name: 'idx_applicants_applications_on_applicant_id_and_application_id'
      t.index %w(batch_application_id batch_applicant_id), name: 'idx_applications_applicants_on_application_id_and_applicant_id'
    end

    create_table 'round_stages', id: :serial, force: :cascade do |t|
      t.integer 'application_stage_id'
      t.datetime 'starts_at'
      t.datetime 'ends_at'
      t.datetime 'created_at', null: false
      t.datetime 'updated_at', null: false
      t.integer 'application_round_id'
      t.index ['application_round_id'], name: 'index_round_stages_on_application_round_id'
      t.index ['application_stage_id'], name: 'index_round_stages_on_application_stage_id'
    end

    add_column :payments, :batch_applicant_id, :integer
    add_index :payments, :batch_applicant_id
    add_column :payments, :original_batch_application_id, :integer
    add_index :payments, :original_batch_application_id
    add_column :payments, :batch_application_id, :integer
    add_index :payments, :batch_application_id
    add_foreign_key :payments, :batch_applications

    add_foreign_key 'application_rounds', 'batches'
    add_foreign_key 'batch_applicants', 'founders'
    add_foreign_key 'batch_applicants', 'users'
    add_foreign_key 'batch_applications', 'application_rounds'
    add_foreign_key 'batch_applications', 'startups'
    add_foreign_key 'round_stages', 'application_rounds'
  end
end
