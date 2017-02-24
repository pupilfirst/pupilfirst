class AddChoreSessionFieldsToTarget < ActiveRecord::Migration[5.0]
  def change
    add_column :targets, :video_embed, :text
    add_column :targets, :last_session_at, :datetime
    add_index :targets, :chore
    add_index :targets, :session_at
  end
end
