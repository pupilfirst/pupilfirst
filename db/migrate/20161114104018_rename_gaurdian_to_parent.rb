class RenameGaurdianToParent < ActiveRecord::Migration[5.0]
  def change
    rename_column :batch_applicants, :guardian_name, :parent_name
  end
end
