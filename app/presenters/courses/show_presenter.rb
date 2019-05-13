module Courses
  class ShowPresenter < ApplicationPresenter
    def initialize(view_context, course)
      @course = course
      super(view_context)
    end

    def json_props
      camelize_keys(
        authenticity_token: view.form_authenticity_token,
        school_name: current_school.name,
        course: course_details,
        levels: levels,
        target_groups: target_groups,
        targets: targets,
        submissions: submissions,
        team: current_student.startup.name,
        students: students,
        user_profiles: user_profiles
      ).to_json
    end

    def page_title
      "#{@course.name} | #{current_school.name}"
    end

    def course_details
      @course.attributes.slice('id', 'name', 'max_grade', 'pass_grade', 'grade_labels', 'ends_at')
    end

    def levels
      @course.levels.map do |level|
        level.attributes.slice('id', 'name', 'number', 'unlock_on')
      end
    end

    def target_groups
      @course.target_groups.where(archived: false).map do |target_group|
        target_group.attributes.slice('id', 'level_id', 'name', 'description', 'sort_index', 'milestone')
      end
    end

    def targets
      attributes = 'id', 'role', 'title', 'target_group_id', 'sort_index', 'resubmittable'

      @course.targets.where(archived: false).select(attributes).map do |target|
        target.attributes.slice(attributes)
      end
    end

    def submissions
      current_student.timeline_events.where(latest: true).map do |timeline_event|
        timeline_event.attributes.slice('target_id', 'passed_at')
      end
    end

    def students
      team_members.pluck(:id, :user_id)
    end

    def user_profiles
      UserProfile.where(school: current_school, user_id: team_members.pluck(:user_id)).with_attached_avatar.map do |user_profile|
        profile = user_profile.attributes.slice('user_id', 'name')
        profile['avatar_url'] = view.url_for(user_profile.avatar_variant(:thumb)) if user_profile.avatar.attached?
        profile
      end
    end

    private

    def team_members
      @team_members ||= current_student.startup.founders.load
    end

    def current_student
      @current_student ||= @course.founders.find_by(user_id: current_user.id)
    end
  end
end
