class AddLegalRegisteredNameToStartups < ActiveRecord::Migration
  def change
    add_column :startups, :legal_registered_name, :string
  end
end
