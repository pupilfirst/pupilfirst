class AddAffiliationFieldToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :affiliation, :string
  end
end
