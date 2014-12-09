class AddIncubationLocationToStatistic < ActiveRecord::Migration
  def change
    add_column :statistics, :incubation_location, :string
  end
end
