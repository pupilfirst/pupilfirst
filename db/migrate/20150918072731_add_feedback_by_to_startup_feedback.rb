class AddFeedbackByToStartupFeedback < ActiveRecord::Migration[4.2]
  def change
    add_column :startup_feedback, :feedback_by, :integer
    add_index :startup_feedback, :feedback_by
  end
end
