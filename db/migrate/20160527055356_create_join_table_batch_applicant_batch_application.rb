class CreateJoinTableBatchApplicantBatchApplication < ActiveRecord::Migration
  def change
    create_join_table :batch_applicants, :batch_applications do |t|
      t.index [:batch_applicant_id, :batch_application_id], name: 'idx_applicants_applications_on_applicant_id_and_application_id'
      t.index [:batch_application_id, :batch_applicant_id], name: 'idx_applications_applicants_on_application_id_and_applicant_id'
    end
  end
end
