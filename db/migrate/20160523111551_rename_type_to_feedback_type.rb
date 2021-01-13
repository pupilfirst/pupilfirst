class RenameTypeToFeedbackType < ActiveRecord::Migration[4.2]
  def change
    rename_column :platform_feedback, :type, :feedback_type
  end
end
