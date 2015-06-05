class AddStartupRefToTimelines < ActiveRecord::Migration
  def change
    add_reference :timelines, :startup, index: true, foreign_key: true
  end
end
