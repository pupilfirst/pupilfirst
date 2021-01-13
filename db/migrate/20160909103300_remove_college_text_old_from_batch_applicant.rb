class RemoveCollegeTextOldFromBatchApplicant < ActiveRecord::Migration[4.2]
  def change
    remove_column :batch_applicants, :college_text_old, :string
  end
end
