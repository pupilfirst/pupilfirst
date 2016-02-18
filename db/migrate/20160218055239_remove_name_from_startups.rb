class RemoveNameFromStartups < ActiveRecord::Migration
  def change
    remove_column :startups, :name, :string
  end
end
