module Courses
  class ReportPresenter < ApplicationPresenter
    def initialize(view_context, course)
      @course = course
      super(view_context)
    end

    def page_title
      "#{I18n.t('presenters.courses.report.student_report')} | #{@course.name} | #{current_school.name}"
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
        level
          .attributes
          .slice('id', 'name', 'number')
          .merge(unlocked: level.unlocked?)
      end
    end

    def current_student
      @current_student ||=
        @course.students.not_dropped_out.find_by(user_id: current_user.id)
    end

    def coaches
      team_coaches = current_student.faculty

      return [] if team_coaches.empty?

      team_coaches
        .includes(:user)
        .map do |coach|
          {
            name: coach.name,
            title: coach.title,
            avatar_url:
              if coach.avatar.attached?
                view.rails_public_blob_url(coach.user.avatar_variant(:thumb))
              else
                nil
              end
          }
        end
    end
  end
end
