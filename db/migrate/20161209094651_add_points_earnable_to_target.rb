class AddPointsEarnableToTarget < ActiveRecord::Migration[5.0]
  def change
    add_column :targets, :points_earnable, :integer
  end
end
