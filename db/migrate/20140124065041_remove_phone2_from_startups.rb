class RemovePhone2FromStartups < ActiveRecord::Migration
  def change
  	remove_column :startups, :phone2
  end
end
