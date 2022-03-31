class RemoveStartupFromStarupFeedback < ActiveRecord::Migration[6.1]
  def change
    remove_column :startup_feedback, :startup_id, :integer
  end
end
