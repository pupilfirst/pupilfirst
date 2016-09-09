class RemoveCollegeTextOldFromBatchApplicant < ActiveRecord::Migration
  def change
    remove_column :batch_applicants, :college_text_old, :string
  end
end
