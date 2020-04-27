module Courses
  class ReportPresenter < ApplicationPresenter
    def initialize(view_context, course)
      @course = course
      super(view_context)
    end

    def page_title
      "Student Report | #{@course.name} | #{current_school.name}"
    end

    def props
      {
        total_targets: total_targets,
        targets_completed: targets_completed,
        completed_level_ids: completed_level_ids,
        levels: level_details,
        quiz_scores: quiz_scores,
        evaluation_criteria: evaluation_criteria,
        average_grades: average_grades,
        coaches: coaches
      }
    end

    private

    def completed_level_ids
      required_targets_by_level = Target.live.joins(:target_group).where(target_groups: { milestone: true, level_id: levels.unlocked.select(:id) }).distinct(:id)
        .pluck(:id, 'target_groups.level_id').each_with_object({}) do |(target_id, level_id), required_targets_by_level|
        required_targets_by_level[level_id] ||= []
        required_targets_by_level[level_id] << target_id
      end

      passed_target_ids = TimelineEvent.joins(:founders).where(founders: { id: student.id }).where.not(passed_at: nil).distinct(:target_id).pluck(:target_id)

      levels.pluck(:id).select do |level_id|
        ((required_targets_by_level[level_id] || []) - passed_target_ids).empty?
      end
    end

    def average_grades
      @average_grades ||= TimelineEventGrade.where(timeline_event: submissions).group(:evaluation_criterion_id).average(:grade).map do |ec_id, average_grade|
        { evaluation_criterion_id: ec_id, average_grade: average_grade.round(1) }
      end
    end

    def targets_completed
      submissions.passed.distinct(:target_id).count(:target_id)
    end

    def total_targets
      @course.targets.live.count
    end

    def level_details
      levels.map { |level| level.attributes.slice('id', 'number') }
    end

    def levels
      @levels ||= @course.levels.where.not(number: 0)
    end

    def student
      @student ||= @course.founders.where(user_id: current_user.id).first
    end

    def submissions
      student.timeline_events
    end

    def quiz_scores
      submissions.where.not(quiz_score: nil).pluck(:quiz_score)
    end

    def coaches
      student.startup.faculty.includes(:user).map { |coach| { id: coach.user.id, title: coach.title, name: coach.name, avatar_url: coach.user.avatar_url } }
    end

    def evaluation_criteria
      EvaluationCriterion.where(id: average_grades.pluck(:evaluation_criterion_id)).map do |ec|
        {
          id: ec.id,
          name: ec.name,
          max_grade: ec.max_grade,
          pass_grade: ec.pass_grade
        }
      end
    end
  end
end
