class RemoveSharesFromPartnership < ActiveRecord::Migration
  def up
    remove_column :partnerships, :shares
  end

  def down
    add_column :partnerships, :shares, :integer
  end
end
