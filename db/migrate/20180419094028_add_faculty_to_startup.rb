class AddFacultyToStartup < ActiveRecord::Migration[5.1]
  def change
    add_reference :startups, :faculty
  end
end
