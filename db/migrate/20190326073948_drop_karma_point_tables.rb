class DropKarmaPointTables < ActiveRecord::Migration[5.2]
  def up
    drop_table :weekly_karma_points
    drop_table :karma_points
  end

  def down
    create_table :karma_points do |t|
      t.integer :founder_id
      t.integer :points
      t.string :activity_type
      t.integer :source_id
      t.string :source_type
      t.integer :startup_id
      t.timestamps
    end

    add_index :karma_points, :founder_id
    add_index :karma_points, :source_id
    add_index :karma_points, :startup_id

    create_table :weekly_karma_points do |t|
      t.datetime :week_starting_at
      t.references :startup, foreign_key: true
      t.references :level, foreign_key: true
      t.integer :points
    end

    add_index :weekly_karma_points, %i[week_starting_at level_id]
  end
end
