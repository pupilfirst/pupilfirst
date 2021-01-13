class AddCompletionCommentToTarget < ActiveRecord::Migration[4.2]
  def change
    add_column :targets, :completion_comment, :text
  end
end
