class AddStartupToStartupFeedbacks < ActiveRecord::Migration[4.2]
  def change
    add_column :startup_feedbacks, :startup_id, :integer
  end
end
