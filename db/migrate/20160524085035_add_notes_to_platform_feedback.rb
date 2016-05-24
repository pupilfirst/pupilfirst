class AddNotesToPlatformFeedback < ActiveRecord::Migration
  def change
    add_column :platform_feedback, :notes, :text
  end
end
