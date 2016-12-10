class RenameIconToIconName < ActiveRecord::Migration[5.0]
  def change
    rename_column :program_weeks, :icon, :icon_name
  end
end
