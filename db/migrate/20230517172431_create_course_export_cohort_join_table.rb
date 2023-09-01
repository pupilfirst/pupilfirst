class CreateCourseExportCohortJoinTable < ActiveRecord::Migration[6.1]
  def change
    create_table :course_exports_cohorts do |t|
      t.belongs_to :cohort, index: true
      t.belongs_to :course_export, index: true
    end
  end
end
