class CreateEvaluationCriteriaAndGradesForEvents < ActiveRecord::Migration[5.2]
  def up
    Course.all.each do |course|
      course.update!(pass_grade: 2, grade_labels: grade_labels, max_grade: 5)

      criterion = EvaluationCriterion.create!(
        course: course,
        name: 'Quality',
        description: 'Quality of submission'
      )

      auto_verified_targets = course.targets.where(submittability: 'auto_verify')
      auto_verified_events = TimelineEvent.where(target: auto_verified_targets)
      auto_verified_events.each do |event|
        event.update!(passed_at: event.status_updated_at)
      end

      non_auto_verified_targets = course.targets.where.not(id: auto_verified_targets)
      non_auto_verified_targets.each do |target|
        target.evaluation_criteria << criterion
      end

      non_auto_verified_events = TimelineEvent.where(target: non_auto_verified_targets)
      faculty = course.faculty.first

      not_accepted_events = non_auto_verified_events.where(status: 'Not Accepted')
      not_accepted_events.each do |event|
        event.update!(evaluator: faculty)
        TimelineEventGrade.create!(timeline_event: event, evaluation_criterion: criterion, grade: 1)
      end

      needs_improvement_events = non_auto_verified_events.where(status: 'Needs Improvement')
      needs_improvement_events.each do |event|
        event.update!(evaluator: faculty, passed_at: event.status_updated_at)
        TimelineEventGrade.create!(timeline_event: event, evaluation_criterion: criterion, grade: 2)
      end

      verified_events = non_auto_verified_events.where(status: 'Verified')
      verified_events.each do |event|
        grade = grade_from_score[event.score.to_i]
        event.update!(evaluator: faculty, passed_at: event.status_updated_at)
        TimelineEventGrade.create!(timeline_event: event, evaluation_criterion: criterion, grade: grade)
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def grade_labels
    {
      1 => 'Not Accepted',
      2 => 'Needs Improvement',
      3 => 'Good',
      4 => 'Great',
      5 => 'Wow'
    }
  end

  def grade_from_score
    {
      0 => 3,
      1 => 3,
      2 => 4,
      3 => 5
    }
  end
end
