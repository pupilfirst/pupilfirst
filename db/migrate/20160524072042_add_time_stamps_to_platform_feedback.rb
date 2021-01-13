class AddTimeStampsToPlatformFeedback < ActiveRecord::Migration[4.2]
  def change
    change_table(:platform_feedback) { |t| t.timestamps }
  end
end
