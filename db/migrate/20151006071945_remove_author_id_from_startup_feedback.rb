class RemoveAuthorIdFromStartupFeedback < ActiveRecord::Migration
  def up
    remove_column :startup_feedback, :author_id
  end

  def down
    add_column :startup_feedback, :author_id, :integer
    add_index :startup_feedback, :author_id
  end
end
