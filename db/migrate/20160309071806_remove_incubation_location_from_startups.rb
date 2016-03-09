class RemoveIncubationLocationFromStartups < ActiveRecord::Migration
  def change
    remove_column :startups, :incubation_location, :string
  end
end
