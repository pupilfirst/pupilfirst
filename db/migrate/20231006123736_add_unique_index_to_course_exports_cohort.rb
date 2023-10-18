class AddUniqueIndexToCourseExportsCohort < ActiveRecord::Migration[6.1]

  class CourseExportsCohort < ApplicationRecord; end

  def up
    puts 'Finding duplicate records for CourseExportsCohort...'
    CourseExportsCohort.select('MAX(id) as max_id, course_export_id, cohort_id')
                       .group(:course_export_id, :cohort_id)
                       .having('COUNT(*) > 1')
                       .each do |duplicate|
      most_recent_record = CourseExportsCohort.where(course_export_id: duplicate.course_export_id,
                                                     cohort_id: duplicate.cohort_id)
                                              .order(id: :desc)
                                              .first
      CourseExportsCohort.where(course_export_id: duplicate.course_export_id,
                                cohort_id: duplicate.cohort_id)
                         .where.not(id: most_recent_record.id)
                         .delete_all
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
