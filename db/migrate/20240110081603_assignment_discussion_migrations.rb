class AssignmentDiscussionMigrations < ActiveRecord::Migration[7.0]
  def change
    add_column :assignments, :discussion, :boolean, default: false
    add_column :assignments, :allow_anonymous, :boolean, default: false

    add_column :timeline_events, :anonymous, :boolean, default: false
    add_column :timeline_events, :pinned, :boolean, default: false

    create_table :submission_comments do |t|
      t.text :comment
      t.references :user, null: false, foreign_key: true
      t.references :timeline_event, null: false, foreign_key: true

      t.timestamps
    end

    create_table :submission_moderations do |t|
      t.text :reason
      t.references :user, null: false, foreign_key: true
      t.references :timeline_event, null: false, foreign_key: true

      t.timestamps
    end

    create_table :reactions do |t|
      t.string :reaction_value
      t.references :user, null: false, foreign_key: true
      t.references :reactionable, polymorphic: true, null: false

      t.timestamps
    end
  end
end
