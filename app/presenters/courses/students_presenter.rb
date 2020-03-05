module Courses
  class StudentsPresenter < ApplicationPresenter
    def initialize(view_context, course)
      @course = course
      super(view_context)
    end

    def page_title
      "Students In Course | #{@course.name} | #{current_school.name}"
    end

    def team_coaches
      school = @course.school

      school.faculty
        .joins(startups: :course)
        .where(startups: { courses: { id: @course.id } })
        .includes(user: { avatar_attachment: :blob })
        .distinct.map do |coach|
        user = coach.user

        coach_details = {
          id: coach.id,
          user_id: user.id,
          name: user.name,
          title: user.full_title
        }

        coach_details[:avatar_url] = view.rails_representation_path(user.avatar_variant(:thumb), only_path: true) if user.avatar.attached?
        coach_details
      end
    end

    private

    def props
      {
        levels: levels,
        course: course_details,
        user_id: current_user.id,
        team_coaches: team_coaches
      }
    end

    def levels
      @course.levels.map do |level|
        level_attributes = level.attributes.slice('id', 'name', 'number')
        level_attributes.merge!(teams_in_level: level.startups.active.count)
      end
    end

    def course_details
      { id: @course.id }
    end
  end
end
