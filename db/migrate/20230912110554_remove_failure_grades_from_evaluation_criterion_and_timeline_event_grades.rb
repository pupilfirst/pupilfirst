class RemoveFailureGradesFromEvaluationCriterionAndTimelineEventGrades < ActiveRecord::Migration[6.1]

  class TimelineEvent < ApplicationRecord
    has_many :timeline_event_grades, dependent: :destroy
  end

  class TimelineEventGrade < ApplicationRecord
    belongs_to :timeline_event
  end

  def up

    # remove all grades below pass grade
    EvaluationCriterion.find_each do |ec|
      grades_removed = (ec.pass_grade - 1 )
      new_max_grade = ec.max_grade - grades_removed
      new_grade_labels = ec.grade_labels.reject {|grade_label| grade_label['grade'] < ec.pass_grade}
      new_grade_labels.each {|grade_label| grade_label['grade'] -= grades_removed}
      ec.update!(max_grade: new_max_grade, pass_grade: 1, grade_labels: new_grade_labels)
      # change all existing grades to match the new max grade
      ec.timeline_event_grades.in_batches.update_all("grade = grade - #{grades_removed}")
    end

    # destroy all failed timeline event grades
    failed_timeline_event_grades = TimelineEventGrade.joins(:timeline_event).where(timeline_events: {:passed_at=>nil}).where.not(timeline_events: {:evaluated_at=>nil})
    failed_timeline_event_grades.destroy_all

  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
