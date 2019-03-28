class RemovePointsEarnableFromTarget < ActiveRecord::Migration[5.2]
  def change
    remove_column :targets, :points_earnable, :integer
  end
end
