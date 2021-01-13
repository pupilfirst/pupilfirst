class RemoveWomenEmployeesFromStartups < ActiveRecord::Migration[4.2]
  def change
    remove_column :startups, :women_employees, :integer
  end
end
