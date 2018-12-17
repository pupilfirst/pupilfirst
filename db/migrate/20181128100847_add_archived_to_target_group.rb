class AddArchivedToTargetGroup < ActiveRecord::Migration[5.2]
  def change
    add_column :target_groups, :archived, :boolean, default: false
  end
end
