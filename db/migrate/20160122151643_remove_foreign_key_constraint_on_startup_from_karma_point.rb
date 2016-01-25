class RemoveForeignKeyConstraintOnStartupFromKarmaPoint < ActiveRecord::Migration
  def change
    remove_foreign_key :karma_points, :startups
  end
end
