class AddAttachmentToStartupFeedback < ActiveRecord::Migration
  def change
    add_column :startup_feedback, :attachment, :string
  end
end
