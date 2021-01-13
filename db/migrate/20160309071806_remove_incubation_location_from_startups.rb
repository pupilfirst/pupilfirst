class RemoveIncubationLocationFromStartups < ActiveRecord::Migration[4.2]
  def change
    remove_column :startups, :incubation_location, :string
  end
end
