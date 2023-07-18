class RenameTableFoundersToStudents < ActiveRecord::Migration[6.1]
  class TimelineEventOwner < ApplicationRecord
  end

  class LeaderboardEntry < ApplicationRecord
  end

  class FacultyStudentEnrollment < ApplicationRecord
  end

  def up
    # Step 1: Rename founders to students
    rename_table :founders, :students
    rename_table :faculty_founder_enrollments, :faculty_student_enrollments

    # Step 2: Add new student_id columns
    add_reference :timeline_event_owners, :student, foreign_key: true
    add_reference :leaderboard_entries, :student, foreign_key: true
    add_reference :faculty_student_enrollments, :student, foreign_key: true

    # Step 3: Copy founder_id to student_id
    TimelineEventOwner.find_each do |teo|
      teo.update(student_id: teo.founder_id)
    end

    LeaderboardEntry.find_each { |le| le.update(student_id: le.founder_id) }

    FacultyStudentEnrollment.find_each do |fse|
      fse.update(student_id: fse.founder_id)
    end

    # Step 4: Remove references
    remove_reference :timeline_event_owners, :founder
    remove_reference :leaderboard_entries, :founder
    remove_reference :faculty_student_enrollments, :founder

    add_index :faculty_student_enrollments,
              %i[faculty_id student_id],
              unique: true
    add_index :leaderboard_entries,
              %i[student_id period_from period_to],
              unique: true,
              name: :index_leaderboard_on_student_id_and_period_from_and_to
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
