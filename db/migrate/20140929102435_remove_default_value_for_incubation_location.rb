class RemoveDefaultValueForIncubationLocation < ActiveRecord::Migration
  def up
    change_column :startups, :incubation_location, :string, default: nil
  end

  def down
    change_column :startups, :incubation_location, :string, default: 'kochi'
  end
end
