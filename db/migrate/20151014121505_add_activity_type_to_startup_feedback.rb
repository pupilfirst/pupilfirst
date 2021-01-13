class AddActivityTypeToStartupFeedback < ActiveRecord::Migration[4.2]
  def change
    add_column :startup_feedback, :activity_type, :string
  end
end
