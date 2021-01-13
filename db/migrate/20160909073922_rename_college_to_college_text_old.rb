class RenameCollegeToCollegeTextOld < ActiveRecord::Migration[4.2]
  def change
    rename_column :batch_applicants, :college, :college_text_old
  end
end
