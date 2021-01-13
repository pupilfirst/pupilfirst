class RemoveDefaultValueForIncubationLocation < ActiveRecord::Migration[4.2]
  def up
    change_column :startups, :incubation_location, :string, default: nil
  end

  def down
    change_column :startups, :incubation_location, :string, default: 'kochi'
  end
end
