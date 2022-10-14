class AddCompletedAtToFounders < ActiveRecord::Migration[6.1]
  def change
    add_column :founders, :completed_at, :datetime
  end
end
