class RemoveMorePartnershipFieldsFromUser < ActiveRecord::Migration
  def up
    remove_column :users, :is_director
    remove_column :users, :number_of_shares
    remove_column :users, :is_share_holder
    remove_column :users, :bank_id
  end

  def down
    add_column :users, :is_director, :boolean, default: false
    add_column :users, :number_of_shares, :integer
    add_column :users, :is_share_holder, :boolean
    add_reference :users, :bank, index: true
  end
end
