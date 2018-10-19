class AddUniqueIndexToFacultyStartups < ActiveRecord::Migration[5.2]
  def change
    remove_index :faculty_startups, :faculty_id
    add_index :faculty_startups, %i[faculty_id startup_id], unique: true
  end
end
