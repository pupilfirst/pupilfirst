class RemoveForeignKeyConstraintOnUserForKarmaPoint < ActiveRecord::Migration
  def change
    remove_foreign_key :karma_points, :users
  end
end
