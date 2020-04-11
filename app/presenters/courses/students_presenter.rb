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

    def current_coach_details
      coach = current_user.faculty

      details = {
        id: coach.id,
        user_id: current_user.id,
        name: current_user.name,
        title: current_user.full_title
      }

      details[:avatar_url] = view.rails_representation_path(current_user.avatar_variant(:thumb), only_path: true) if current_user.avatar.attached?
      details
    end

    private

    def props
      {
        levels: levels,
        course: course_details,
        user_id: current_user.id,
        team_coaches: team_coaches,
        current_coach: current_coach_details
      }
    end

    def levels
      @course.levels.map do |level|
        level_attributes = level.attributes.slice('id', 'name', 'number')
        teams_in_level = level.startups.active
        students_in_level = Founder.where(startup: teams_in_level)
        level_attributes.merge!(students_in_level: students_in_level.count, teams_in_level: teams_in_level.count, unlocked: level.unlocked?)
      end
    end

    def course_details
      { id: @course.id }
    end
  end
end
