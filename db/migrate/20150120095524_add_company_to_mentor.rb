class AddCompanyToMentor < ActiveRecord::Migration[4.2]
  def change
    add_column :mentors, :company, :string
  end
end
