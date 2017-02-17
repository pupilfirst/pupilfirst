class AddSessionChoreColoumnsToTarget < ActiveRecord::Migration[5.0]
  def change
    add_column :targets, :session_at, :datetime
    add_column :targets, :chore, :boolean, default: false
  end
end
