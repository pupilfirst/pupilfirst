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
        student_id: current_student.id,
        levels: levels,
        coaches: coaches,
        team_student_ids: current_student.team_student_ids
      }
    end

    private

    def levels
      @course.levels.map do |level|
        level.attributes.slice('id', 'name', 'number').merge(unlocked: level.unlocked?)
      end
    end

    def current_student
      @current_student ||= @course.founders.not_dropped_out.find_by(user_id: current_user.id)
    end

    def coaches
      team_coaches = current_founder.startup&.faculty

      return [] if team_coaches.empty?

      team_coaches.includes(:user).map do |coach|
        {
          name: coach.name,
          title: coach.title,
          avatar_url: coach.avatar.attached? ? view.rails_representation_path(coach.user.avatar_variant(:thumb), only_path: true) : nil
        }
      end
    end
  end
end
