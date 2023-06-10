class RemoveFailureGradesEvaluationCriterion < ActiveRecord::Migration[6.1]
  def up

    # remove all grades below pass grade
    EvaluationCriterion.find_each do |ec|
      new_max_grade = ec.max_grade - (ec.pass_grade - 1 )
      new_grade_labels = ec.grade_labels.reject {|grade_label| grade_label['grade'] < ec.pass_grade}
      new_grade_labels.each {|grade_label| grade_label['grade'] -= (ec.pass_grade - 1)}
      ec.update!(max_grade: new_max_grade, pass_grade: 1, grade_labels: new_grade_labels)
    end

    # destroy all failed timeline event grades
    failed_timeline_event_grades = TimelineEventGrade.joins(:timeline_event).where(timeline_events: {:passed_at=>nil}).where.not(timeline_events: {:evaluated_at=>nil})
    failed_timeline_event_grades.destroy_all

  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
