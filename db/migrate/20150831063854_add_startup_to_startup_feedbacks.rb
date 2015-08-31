class AddStartupToStartupFeedbacks < ActiveRecord::Migration
  def change
    add_column :startup_feedbacks, :startup_id, :integer
  end
end
