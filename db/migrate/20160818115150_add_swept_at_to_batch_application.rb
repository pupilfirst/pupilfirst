class AddSweptAtToBatchApplication < ActiveRecord::Migration[4.2]
  def change
    add_column :batch_applications, :swept_at, :datetime
  end
end
