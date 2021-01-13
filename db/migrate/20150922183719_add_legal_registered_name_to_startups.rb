class AddLegalRegisteredNameToStartups < ActiveRecord::Migration[4.2]
  def change
    add_column :startups, :legal_registered_name, :string
  end
end
