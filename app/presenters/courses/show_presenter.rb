module Courses
  class ShowPresenter < ApplicationPresenter
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
        school_name: current_school.name,
        course: course_details,
        levels: levels,
        target_groups: target_groups,
        targets: targets,
        submissions: submissions,
        team: team_details,
        students: team_members.map(&:attributes),
        coaches: faculty.map(&:attributes),
        user_profiles: user_profiles,
        current_user_id: current_user.id
      }
    end

    def team_details
      current_student.startup.attributes.slice('name', 'access_ends_at', 'level_id')
    end

    def course_details
      details = @course.attributes.slice('id', 'name', 'max_grade', 'pass_grade', 'ends_at')

      details['grade_labels'] = @course.grade_labels.map do |key, value|
        { grade: key, label: value }
      end

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

      scope = @course.targets.joins(:target_group).includes(:target_prerequisites)
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

    def user_profiles
      user_ids = (team_members.pluck(:user_id) + faculty.pluck(:user_id)).uniq

      UserProfile.where(school: current_school, user_id: user_ids).with_attached_avatar.map do |user_profile|
        profile = user_profile.attributes.slice('user_id', 'name')
        profile['avatar_url'] = user_profile.avatar.attached? ? view.url_for(user_profile.avatar_variant(:thumb)) : nil
        profile
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
