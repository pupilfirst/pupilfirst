class AddIncomeRelatedFieldsToBatchApplicant < ActiveRecord::Migration[5.0]
  def change
    add_column :batch_applicants, :income_proof, :string
    add_column :batch_applicants, :letter_from_parent, :string
    add_column :batch_applicants, :college_contact, :string
  end
end
