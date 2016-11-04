class AddStage4FieldsToBatchApplicant < ActiveRecord::Migration[5.0]
  def change
    add_column :batch_applicants, :born_on, :date
    add_column :batch_applicants, :guardian_name, :string
    add_column :batch_applicants, :guardian_relation, :string
    add_column :batch_applicants, :current_address, :text
    add_column :batch_applicants, :permanent_address, :text
    add_column :batch_applicants, :id_proof_number, :string
    add_column :batch_applicants, :id_proof, :string
    add_column :batch_applicants, :address_proof, :string
  end
end
