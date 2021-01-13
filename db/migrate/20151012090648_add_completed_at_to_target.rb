class AddCompletedAtToTarget < ActiveRecord::Migration[4.2]
  def change
    add_column :targets, :completed_at, :datetime
  end
end
