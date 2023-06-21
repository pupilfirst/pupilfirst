module Organisations
  class StudentPresenter < ApplicationPresenter
    def initialize(view_context, student)
      @student = student
      super(view_context)
    end

    def student
      @student
    end

    def organisation
      @student.user.organisation
    end

    def cohort
      @student.cohort
    end

    def average_grades
      @average_grades ||=
        begin
          averaged =
            TimelineEventGrade
              .where(timeline_event: submissions_for_grades)
              .group(:evaluation_criterion_id)
              .average(:grade)
              .map do |ec_id, average_grade|
                {
                  evaluation_criterion_id: ec_id,
                  average_grade: average_grade.round(1)
                }
              end

          criteria =
            EvaluationCriterion
              .where(id: averaged.pluck(:evaluation_criterion_id))
              .each_with_object({}) do |ec, criteria|
                criteria[ec.id] = { name: ec.name, max_grade: ec.max_grade }
              end

          averaged.map do |average_grade|
            merged =
              average_grade.merge(
                criteria[average_grade[:evaluation_criterion_id]]
              )

            merged[:percentage] = (
              (merged[:average_grade] / merged[:max_grade]) * 100
            ).floor

            merged
          end
        end
    end

    def targets_completed
      @targets_completed ||=
        latest_submissions.passed.distinct(:target_id).count(:target_id)
    end

    def total_targets
      @total_targets ||= current_course_targets.count
    end

    def target_completion_percentage
      if total_targets.zero?
        0
      else
        ((targets_completed.to_f / total_targets) * 100).floor
      end
    end

    def coach_notes
      if @student.user.organisations.exists?(id: @student.user.organisation)
        CoachNote.none
      else
        @student.coach_notes.not_archived
      end
    end

    def submissions_pending_review
      latest_submissions.pending_review.order(created_at: :desc)
    end

    def reviewed_submissions
      paged =
        student
          .timeline_events
          .evaluated_by_faculty
          .joins(:target)
          .where(targets: { id: current_course_targets })
          .includes(target: :level)
          .order(created_at: :desc)
          .page(params[:page])
          .per(10)

      paged.count.zero? ? paged.page(paged.total_pages) : paged
    end

    def reviewed_submissions_passed_count
      reviewed_submissions.except(:limit, :offset).passed.count
    end

    def reviewed_submissions_failed_count
      reviewed_submissions.except(:limit, :offset).failed.count
    end

    private

    def current_course_targets
      course.targets.live.joins(:level).where.not(levels: { number: 0 })
    end

    def course
      @course ||= student.course
    end

    def team
      @team ||= student.team
    end

    def latest_submissions
      @latest_submissions ||=
        student
          .latest_submissions
          .joins(:target)
          .where(targets: { id: current_course_targets })
    end

    def completed_level_ids
      @completed_level_ids ||=
        begin
          required_targets_by_level =
            Target
              .live
              .joins(:target_group)
              .where(
                target_groups: {
                  milestone: true,
                  level_id: levels.select(:id)
                }
              )
              .distinct(:id)
              .pluck(:id, "target_groups.level_id")
              .each_with_object(
                {}
              ) do |(target_id, level_id), required_targets_by_level|
                required_targets_by_level[level_id] ||= []
                required_targets_by_level[level_id] << target_id
              end

          passed_target_ids =
            TimelineEvent
              .joins(:founders)
              .where(founders: { id: student.id })
              .where.not(passed_at: nil)
              .distinct(:target_id)
              .pluck(:target_id)

          levels
            .pluck(:id)
            .select do |level_id|
              (
                (required_targets_by_level[level_id] || []) - passed_target_ids
              ).empty?
            end
        end
    end

    def submissions_for_grades
      latest_submissions
        .includes(:founders, :target)
        .select do |submission|
          submission.target.individual_target? ||
            (submission.founder_ids.sort == student.team_student_ids)
        end
    end
  end
end
