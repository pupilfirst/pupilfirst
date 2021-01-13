class RenameStartupFeedbacksToStartupFeedback < ActiveRecord::Migration[4.2]
  def change
    rename_table :startup_feedbacks, :startup_feedback
  end
end
