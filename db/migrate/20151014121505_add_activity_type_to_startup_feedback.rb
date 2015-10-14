class AddActivityTypeToStartupFeedback < ActiveRecord::Migration
  def change
    add_column :startup_feedback, :activity_type, :string
  end
end
