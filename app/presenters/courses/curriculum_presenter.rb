module Courses
  class CurriculumPresenter < ApplicationPresenter
    def initialize(view_context, course)
      @course = course
      super(view_context)
    end

    def page_title
      "#{@course.name} | #{current_school.name}"
    end

    private

    def props
      if current_student.present?
        {
          submissions: submissions,
          team: team_details,
          coaches: faculty.map(&:attributes),
          users: users,
          evaluation_criteria: evaluation_criteria,
          preview: false,
          team_members_pending: team_members_pending,
          **default_props
        }
      else
        {
          submissions: [],
          team: team_details_for_preview_mode,
          coaches: [],
          users: [],
          evaluation_criteria: [],
          preview: true,
          team_members_pending: false,
          **default_props
        }
      end
    end

    def team_members_pending
      team_member_ids = current_student.startup.founders.where.not(id: current_student.id).pluck(:id)

      milestone_target_ids = Target.joins(target_group: :level).live
        .where(target_groups: { milestone: true, level_id: current_student.startup.level_id })
        .pluck(:id)

      milestone_target_attempted = TimelineEventOwner.joins(:timeline_event).where(
        timeline_events: { target_id: milestone_target_ids },
        founder_id: team_member_ids,
        latest: true
      )

      # When the course has 'strict' progression, we need only consider submissions
      # that have a 'passing' grade. Otherwise, an attempt is considered sufficient.
      scope = if @course.strict?
        milestone_target_attempted.where.not(
          timeline_events: { passed_at: nil }
        )
      else
        milestone_target_attempted
      end

      milestone_target_completion = scope.pluck('timeline_events.target_id', :founder_id)
        .each_with_object({}) do |ids, hash|
        hash[ids[0]] ||= []
        hash[ids[0]] << ids[1]
      end

      all_complete = milestone_target_ids.all? do |target_id|
        completed_founders_ids = milestone_target_completion[target_id] || []
        (team_member_ids - completed_founders_ids).blank?
      end

      !all_complete
    end

    def default_props
      {
        course: course_details,
        levels: levels_details,
        target_groups: target_groups,
        targets: targets,
        access_locked_levels: access_locked_levels
      }
    end

    def evaluation_criteria
      @course.evaluation_criteria.map do |ec|
        ec.attributes.slice('id', 'name', 'max_grade', 'pass_grade', 'grade_labels')
      end
    end

    def team_details_for_preview_mode
      {
        name: current_user.name,
        level_id: levels.first.id,
        access_ends_at: nil
      }
    end

    def team_details
      current_student.startup.attributes.slice('name', 'access_ends_at', 'level_id')
    end

    def course_details
      @course.attributes.slice('id', 'ends_at', 'progression_behavior', 'progression_limit').merge(
        certificate_serial_number: current_user.issued_certificates.joins(:course).find_by(courses: { id: @course.id })&.serial_number
      )
    end

    def levels
      @levels ||= @course.levels.order(number: :DESC).load
    end

    def levels_details
      levels.map do |level|
        level.attributes.slice('id', 'name', 'number', 'unlock_at')
      end
    end

    def target_groups
      scope = @course.target_groups
        .where(level_id: open_level_ids)
        .where(archived: false)

      scope.map do |target_group|
        target_group.attributes.slice('id', 'level_id', 'name', 'description', 'sort_index', 'milestone')
      end
    end

    def targets
      attributes = %w[id role title target_group_id sort_index resubmittable]

      scope = @course.targets.live.joins(:target_group).includes(:target_prerequisites, :evaluation_criteria)
        .where(target_groups: { level_id: open_level_ids })
        .where(archived: false)

      scope.select(*attributes).map do |target|
        details = target.attributes.slice(*attributes)
        details[:prerequisite_target_ids] = target.target_prerequisites.pluck(:prerequisite_target_id)
        details[:reviewed] = target.evaluation_criteria.present?
        details
      end
    end

    def submissions
      current_student.latest_submissions.includes(:target).map do |submission|
        if submission.target.individual_target? || submission.founder_ids.sort == current_student.team_student_ids
          submission.attributes.slice('target_id', 'passed_at', 'evaluated_at')
        end
      end - [nil]
    end

    def faculty
      @faculty ||= begin
        scope = Faculty.left_joins(:startups, :courses)

        scope.where(startups: { id: current_student.startup })
          .or(scope.where(courses: { id: @course }))
          .distinct.select(:id, :user_id).load
      end
    end

    def team_members
      @team_members ||= current_student.startup.founders.select(:id, :user_id).load
    end

    def users
      user_ids = (team_members.pluck(:user_id) + faculty.pluck(:user_id)).uniq

      User.where(id: user_ids).with_attached_avatar.map do |user|
        details = user.attributes.slice('id', 'name', 'title')
        details['avatar_url'] = user.avatar_url(variant: :thumb)
        details
      end
    end

    def current_student
      @current_student ||= @course.founders.not_dropped_out.find_by(user_id: current_user.id)
    end

    # Admins and coaches who have review access in this course have access to locked levels as well.
    def access_locked_levels
      @access_locked_levels ||= begin
        current_school_admin.present? || (current_user.faculty.present? && CoursePolicy.new(pundit_user, @course).review?)
      end
    end

    def open_level_ids
      @open_level_ids ||= begin
        scope = @course.levels

        if access_locked_levels
          scope
        else
          scope.where(unlock_at: nil).or(@course.levels.where('unlock_at <= ?', Time.zone.now))
        end.pluck(:id)
      end
    end
  end
end
