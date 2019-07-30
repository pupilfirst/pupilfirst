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
      {
        authenticity_token: view.form_authenticity_token,
        course: course_details,
        levels: levels,
        target_groups: target_groups,
        targets: targets,
        submissions: submissions,
        team: team_details,
        coaches: faculty.map(&:attributes),
        users: users,
        evaluation_criteria: evaluation_criteria
      }
    end

    def evaluation_criteria
      @course.evaluation_criteria.as_json(only: %i[id name])
    end

    def team_details
      current_student.startup.attributes.slice('name', 'access_ends_at', 'level_id')
    end

    def course_details
      details = @course.attributes.slice('id', 'name', 'max_grade', 'pass_grade', 'ends_at')

      details['grade_labels'] = @course.grade_labels_to_props
      details
    end

    def levels
      @course.levels.map do |level|
        level.attributes.slice('id', 'name', 'number', 'unlock_on')
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

      scope = @course.targets.live.joins(:target_group).includes(:target_prerequisites)
        .where(target_groups: { level_id: open_level_ids })
        .where(archived: false)

      scope.select(*attributes).map do |target|
        details = target.attributes.slice(*attributes)
        details[:prerequisite_target_ids] = target.target_prerequisites.pluck(:prerequisite_target_id)
        details
      end
    end

    def submissions
      current_student.timeline_events.where(latest: true).map do |timeline_event|
        timeline_event.attributes.slice('target_id', 'passed_at', 'evaluator_id')
      end
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
        details['avatar_url'] = user.image_or_avatar_url(variant: :thumb)
        details
      end
    end

    def current_student
      @current_student ||= @course.founders.find_by(user_id: current_user.id)
    end

    def open_level_ids
      @open_level_ids ||= @course.levels.where(unlock_on: nil).or(@course.levels.where('unlock_on <= ?', Date.today)).pluck(:id)
    end
  end
end
