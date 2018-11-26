class RenameSchoolToCourseInEvaluationCriterion < ActiveRecord::Migration[5.2]
  def change
    rename_column :evaluation_criteria, :school_id, :course_id
  end
end
