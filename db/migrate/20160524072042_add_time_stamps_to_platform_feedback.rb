class AddTimeStampsToPlatformFeedback < ActiveRecord::Migration
  def change
    change_table(:platform_feedback) { |t| t.timestamps }
  end
end
