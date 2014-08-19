class AddPartnershipFieldsToUser < ActiveRecord::Migration
  def change
    add_column :users, :managing_director, :boolean, default: false
    add_column :users, :operate_bank_account, :boolean, default: false
    add_column :users, :share_percentage, :integer
    add_column :users, :cash_contribution, :integer
    add_column :users, :salary, :integer
  end
end
