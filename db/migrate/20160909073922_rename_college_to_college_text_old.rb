class RenameCollegeToCollegeTextOld < ActiveRecord::Migration
  def change
    rename_column :batch_applicants, :college, :college_text_old
  end
end
