class AddUniqueIndexToCourseExportsCohort < ActiveRecord::Migration[6.1]

  class CourseExportsCohort < ApplicationRecord; end

  def up
    puts 'Finding duplicate records for CourseExportsCohort...'

    duplicates = CourseExportsCohort.group(
      :course_export_id,
      :cohort_id
    ).having('COUNT(*) > 1')

    if duplicates.exists?
      puts 'Found duplicates...'
      puts 'Deleting the duplicates...'

      duplicate_records = CourseExportsCohort.where(
        course_export_id: duplicates.pluck(:course_export_id),
        cohort_id: duplicates.pluck(:cohort_id)
      )

      duplicate_records.find_each do |duplicate|
        puts "Deleting duplicate for course_exports_cohort.id: #{duplicate.id}..."
        # Find and keep one of the duplicates
        keep_one = CourseExportsCohort.find_by(
          course_export_id: duplicate.course_export_id,
          cohort_id: duplicate.cohort_id
        )

        # Find all duplicates with the same values and delete them
        duplicates_to_delete = CourseExportsCohort.where(
          course_export_id: duplicate.course_export_id,
          cohort_id: duplicate.cohort_id
        ).where.not(id: keep_one.id)

        duplicates_to_delete.delete_all
      end
    end

    puts "Successfully resolved records duplicate issue!"

    add_foreign_key :course_exports_cohorts, :course_exports
    add_foreign_key :course_exports_cohorts, :cohorts

    # Adding indices in both directions
    add_index :course_exports_cohorts, [:course_export_id, :cohort_id], unique: true
    add_index :course_exports_cohorts, [:cohort_id, :course_export_id], unique: true
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
