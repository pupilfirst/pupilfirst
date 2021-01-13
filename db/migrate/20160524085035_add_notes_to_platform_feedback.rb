class AddNotesToPlatformFeedback < ActiveRecord::Migration[4.2]
  def change
    add_column :platform_feedback, :notes, :text
  end
end
