class RemoveWomenEmployeesFromStartups < ActiveRecord::Migration
  def change
    remove_column :startups, :women_employees, :integer
  end
end
