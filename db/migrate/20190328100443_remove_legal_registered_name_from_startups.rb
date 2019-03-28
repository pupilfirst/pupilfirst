class RemoveLegalRegisteredNameFromStartups < ActiveRecord::Migration[5.2]
  def change
    remove_column :startups, :legal_registered_name
  end
end
