class AddPhysicalIncubateeToStartup < ActiveRecord::Migration[4.2]
  def change
    add_column :startups, :physical_incubatee, :boolean
  end
end
