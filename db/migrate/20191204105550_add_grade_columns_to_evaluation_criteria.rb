class AddGradeColumnsToEvaluationCriteria < ActiveRecord::Migration[6.0]
  class Course < ActiveRecord::Base
  end

  class EvaluationCriterion < ActiveRecord::Base
  end

  def change
    add_column :evaluation_criteria, :max_grade, :integer
    add_column :evaluation_criteria, :pass_grade, :integer
    add_column :evaluation_criteria, :grade_labels, :json
    EvaluationCriterion.reset_column_information
    EvaluationCriterion.all.each do |ec|
      ec.update_attributes!(Course.find(ec.course_id).slice(:max_grade, :pass_grade, :grade_labels))
    end
  end
end
