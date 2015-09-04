class RenameStartupFeedbacksToStartupFeedback < ActiveRecord::Migration
  def change
    rename_table :startup_feedbacks, :startup_feedback
  end
end
