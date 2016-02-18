class AddStartupIdToKarmaPoint < ActiveRecord::Migration
  def change
    add_reference :karma_points, :startup, index: true, foreign_key: true
  end
end
