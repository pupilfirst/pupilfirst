class AddProgramWeekIdToTargetGroup < ActiveRecord::Migration[5.0]
  def change
    add_column :target_groups, :program_week_id, :integer
    add_index :target_groups, :program_week_id
  end
end
