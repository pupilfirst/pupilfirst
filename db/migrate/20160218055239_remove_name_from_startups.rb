class RemoveNameFromStartups < ActiveRecord::Migration[4.2]
  def change
    remove_column :startups, :name, :string
  end
end
