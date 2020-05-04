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
        student_id: current_founder&.id,
        levels: levels,
        coaches: coaches
      }
    end

    private

    def levels
      @course.levels.map do |level|
        level.attributes.slice('id', 'name', 'number').merge(unlocked: level.unlocked?)
      end
    end

    def coaches
      team_coaches = current_founder.startup&.faculty
      if team_coaches.present?
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
end
