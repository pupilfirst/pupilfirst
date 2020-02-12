module Courses
  class StudentsPresenter < ApplicationPresenter
    def initialize(view_context, course)
      @course = course
      super(view_context)
    end

    def page_title
      "Students In Course | #{@course.name} | #{current_school.name}"
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
        level_attributes.merge!(teams_in_level: level.startups.count)
      end
    end

    def course_details
      { id: @course.id }
    end

    def team_coaches
      school = @course.school

      school.faculty
        .joins(startups: :course)
        .where(startups: { courses: { id: @course.id } })
        .includes(user: { avatar_attachment: :blob })
        .distinct.map do |faculty|
        user = faculty.user

        user_details = {
          user_id: user.id,
          name: user.name,
          title: user.full_title
        }

        user_details[:avatar_url] = view.rails_representation_path(user.avatar_variant(:thumb), only_path: true) if user.avatar.attached?
        user_details
      end
    end
  end
end
