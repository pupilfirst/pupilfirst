class ChangeLevelUnlockOnToUnlockAt < ActiveRecord::Migration[6.0]
  def up
    change_column :levels, :unlock_on, :datetime
    rename_column :levels, :unlock_on, :unlock_at
  end

  def down
    rename_column :levels, :unlock_at, :unlock_on
    change_column :levels, :unlock_on, :date
  end
end
