class AddAttachmentToStartupFeedback < ActiveRecord::Migration[4.2]
  def change
    add_column :startup_feedback, :attachment, :string
  end
end
