class RemoveCsrFieldsFromMentor < ActiveRecord::Migration
  def change
    remove_column :mentors, :time_donate_percentage, :integer
    remove_column :mentors, :cost_to_company, :integer
  end
end
