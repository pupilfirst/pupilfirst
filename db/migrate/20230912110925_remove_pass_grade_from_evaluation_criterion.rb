class RemovePassGradeFromEvaluationCriterion < ActiveRecord::Migration[6.1]
  def change
    remove_column :evaluation_criteria, :pass_grade
  end
end
