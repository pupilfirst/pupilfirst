class RenameBatchApplicationCollegeToCollegeText < ActiveRecord::Migration[4.2]
  def change
    rename_column :batch_applications, :college, :college_text
  end
end
