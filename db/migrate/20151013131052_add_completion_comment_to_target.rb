class AddCompletionCommentToTarget < ActiveRecord::Migration
  def change
    add_column :targets, :completion_comment, :text
  end
end
