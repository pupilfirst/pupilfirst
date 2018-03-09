class AddUnlockOnToLevel < ActiveRecord::Migration[5.1]
  def change
    add_column :levels, :unlock_on, :date
  end
end
