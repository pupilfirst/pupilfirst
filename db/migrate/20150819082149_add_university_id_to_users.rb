class AddUniversityIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :university_id, :integer
    add_index :users, :university_id
  end
end
