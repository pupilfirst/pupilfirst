class AddCompletedChaptersToMoocStudents < ActiveRecord::Migration[4.2]
  def change
    add_column :mooc_students, :completed_chapters, :text
  end
end
