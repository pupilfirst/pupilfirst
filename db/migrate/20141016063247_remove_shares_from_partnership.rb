class RemoveSharesFromPartnership < ActiveRecord::Migration[4.2]
  def up
    remove_column :partnerships, :shares
  end

  def down
    add_column :partnerships, :shares, :integer
  end
end
