class CreateAssignmentDiscussionTables < ActiveRecord::Migration[7.0]
  def change
    add_column :assignments, :discussion, :boolean, default: false
    add_column :assignments, :allow_anonymous, :boolean, default: false

    add_column :timeline_events, :anonymous, :boolean, default: false
    add_column :timeline_events, :pinned, :boolean, default: false
    add_column :timeline_events, :hidden_at, :datetime

    add_index :timeline_events, :hidden_at

    add_reference :timeline_events,
                  :hidden_by,
                  foreign_key: {
                    to_table: :users
                  }

    create_table :submission_comments do |t|
      t.text :comment
      t.references :user, null: false, foreign_key: true

      t.references :submission,
                   null: false,
                   foreign_key: {
                     to_table: :timeline_events
                   }

      t.references :hidden_by, foreign_key: { to_table: :users }

      t.datetime :hidden_at, index: true
      t.datetime :archived_at, index: true
      t.timestamps
    end

    create_table :moderation_reports do |t|
      t.text :reason

      t.references :user, null: false, foreign_key: true
      t.references :reportable, polymorphic: true, null: false

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
