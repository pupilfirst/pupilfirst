class AddMissingUniqueIndexes < ActiveRecord::Migration[6.0]
  def change
    add_index :applicants, %i[email course_id], unique: true
    remove_index :levels, :number
    add_index :levels, %i[number course_id], unique: true
    add_index :users, %i[email school_id], unique: true
  end
end
