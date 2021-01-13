class RemoveCsrFieldsFromMentor < ActiveRecord::Migration[4.2]
  def change
    remove_column :mentors, :time_donate_percentage, :integer
    remove_column :mentors, :cost_to_company, :integer
  end
end
