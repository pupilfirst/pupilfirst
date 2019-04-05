class RemoveTargetGroupTrack < ActiveRecord::Migration[5.2]
  def up
    remove_reference :target_groups, :track
    drop_table :tracks
  end

  def down
    create_table :tracks do |t|
      t.string :name
      t.integer :sort_index, default: 0
      t.timestamps null: false
    end

    add_reference :target_groups, :track, foreign_key: true
  end
end
