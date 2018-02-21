class RenameVisitingFacultyToVisitingCoaches < ActiveRecord::Migration[5.1]
  def up
    Faculty.where(category: 'visiting_faculty').update_all(category: 'visiting_coaches')
  end

  def down
    Faculty.where(category: 'visiting_coaches').update_all(category: 'visiting_faculty')
  end
end
