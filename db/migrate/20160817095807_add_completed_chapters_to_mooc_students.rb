class AddCompletedChaptersToMoocStudents < ActiveRecord::Migration
  def change
    add_column :mooc_students, :completed_chapters, :text
  end
end
