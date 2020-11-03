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
          level_up_eligibility: level_up_eligibility,
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
          level_up_eligibility: Students::LevelUpEligibilityService::ELIGIBILITY_CURRENT_LEVEL_INCOMPLETE,
          **default_props
        }
      end
    end

    def level_up_eligibility
      Students::LevelUpEligibilityService.new(current_student).eligibility
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
        certificate_serial_number: current_user.issued_certificates.live.joins(:course).find_by(courses: { id: @course.id })&.serial_number
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
