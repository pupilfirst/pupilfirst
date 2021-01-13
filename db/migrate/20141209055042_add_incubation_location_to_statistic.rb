class AddIncubationLocationToStatistic < ActiveRecord::Migration[4.2]
  def change
    add_column :statistics, :incubation_location, :string
  end
end
