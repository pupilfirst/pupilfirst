class CreateWeeklyKarmaPoints < ActiveRecord::Migration[5.0]
  def change
    create_table :weekly_karma_points do |t|
      t.datetime :week_starting_at
      t.references :startup, index: true, foreign_key: true
      t.references :level, index: true, foreign_key: true
      t.integer :points
    end

    add_index :weekly_karma_points, [:week_starting_at, :level_id]
  end
end
