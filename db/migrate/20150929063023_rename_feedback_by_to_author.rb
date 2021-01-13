class RenameFeedbackByToAuthor < ActiveRecord::Migration[4.2]
  def change
    rename_column :startup_feedback, :feedback_by, :author_id
  end
end
