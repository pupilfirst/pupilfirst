class AddCollegeIdentificationToUser < ActiveRecord::Migration
  def change
    add_column :users, :college_identification, :string
  end
end
