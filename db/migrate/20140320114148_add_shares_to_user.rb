class AddSharesToUser < ActiveRecord::Migration
  def change
    add_column :users, :number_of_shares, :integer
    add_column :users, :is_share_holder, :boolean
  end
end
