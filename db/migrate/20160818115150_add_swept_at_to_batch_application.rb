class AddSweptAtToBatchApplication < ActiveRecord::Migration
  def change
    add_column :batch_applications, :swept_at, :datetime
  end
end
