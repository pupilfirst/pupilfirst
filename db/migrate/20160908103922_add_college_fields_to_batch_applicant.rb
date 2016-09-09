class AddCollegeFieldsToBatchApplicant < ActiveRecord::Migration
  def change
    add_reference :batch_applicants, :college, index: true
    add_column :batch_applicants, :college_text, :string
  end
end
