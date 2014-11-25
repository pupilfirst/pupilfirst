class AddPhysicalIncubateeToStartup < ActiveRecord::Migration
  def change
    add_column :startups, :physical_incubatee, :boolean
  end
end
