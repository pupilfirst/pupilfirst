class RemoveForeignKeyConstraintOnUserForKarmaPoint < ActiveRecord::Migration[4.2]
  def change
    remove_foreign_key :karma_points, :users
  end
end
