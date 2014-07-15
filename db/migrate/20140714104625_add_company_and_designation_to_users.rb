class AddCompanyAndDesignationToUsers < ActiveRecord::Migration
  def change
    add_column :users, :company, :string
    add_column :users, :designation, :string
    add_column :users, :is_contact, :boolean
  end
end
