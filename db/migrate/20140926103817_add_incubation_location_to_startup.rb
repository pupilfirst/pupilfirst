class AddIncubationLocationToStartup < ActiveRecord::Migration
  def change
    add_column :startups, :incubation_location, :string, default: 'kochi'
  end
end
