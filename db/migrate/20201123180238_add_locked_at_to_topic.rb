class AddLockedAtToTopic < ActiveRecord::Migration[6.0]
  def change
    add_column :topics, :locked_at, :datetime
    add_reference :topics, :locked_by, foreign_key: { to_table: :users }
  end
end
