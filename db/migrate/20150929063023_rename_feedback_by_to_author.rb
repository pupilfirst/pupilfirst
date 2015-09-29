class RenameFeedbackByToAuthor < ActiveRecord::Migration
  def change
    rename_column :startup_feedback, :feedback_by, :author_id
  end
end
