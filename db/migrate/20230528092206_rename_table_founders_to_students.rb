class RenameTableFoundersToStudents < ActiveRecord::Migration[6.1]
  def change
    remove_reference :timeline_event_owners, :founder
    remove_reference :leaderboard_entries, :founder
    remove_reference :faculty_founder_enrollments, :founder
    rename_table :founders, :students
    rename_table :faculty_founder_enrollments, :faculty_student_enrollments
    add_reference :timeline_event_owners, :student, foreign_key: true
    add_reference :leaderboard_entries, :student, foreign_key: true, index: { unique: true }
    add_reference :faculty_student_enrollments, :student, foreign_key: true
    add_index :faculty_student_enrollments, [:faculty_id, :student_id], unique: true
  end
end
