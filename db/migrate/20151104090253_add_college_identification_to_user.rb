class AddCollegeIdentificationToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :college_identification, :string
  end
end
