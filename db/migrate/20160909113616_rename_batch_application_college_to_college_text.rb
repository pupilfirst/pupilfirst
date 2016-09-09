class RenameBatchApplicationCollegeToCollegeText < ActiveRecord::Migration
  def change
    rename_column :batch_applications, :college, :college_text
  end
end
