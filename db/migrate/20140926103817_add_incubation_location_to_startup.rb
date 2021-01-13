class AddIncubationLocationToStartup < ActiveRecord::Migration[4.2]
  def change
    add_column :startups, :incubation_location, :string, default: 'kochi'
  end
end
