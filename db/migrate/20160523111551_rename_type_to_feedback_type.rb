class RenameTypeToFeedbackType < ActiveRecord::Migration
  def change
    rename_column :platform_feedback, :type, :feedback_type
  end
end
