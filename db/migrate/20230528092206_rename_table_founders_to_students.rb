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
    TimelineEventOwner.update_all("student_id = founder_id")
    LeaderboardEntry.update_all("student_id = founder_id")
    FacultyStudentEnrollment.update_all("student_id = founder_id")

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

    ActsAsTaggableOn::Tagging.where(context: "founder_tags").update_all(
      context: "student_tags"
    )
    ActsAsTaggableOn::Tagging.where(taggable_type: "Founder").update_all(
      taggable_type: "Student"
    )
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
