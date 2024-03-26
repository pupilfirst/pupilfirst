module Courses
  class ReportPresenter < ApplicationPresenter
    def initialize(view_context, course, student)
      @course = course
      @student = student
      super(view_context)
    end

    def page_title
      "#{I18n.t("presenters.courses.report.student_report")} | #{@course.name} | #{current_school.name}"
    end

    def props
      {
        student_id: @student.id,
        coaches: coaches,
        team_student_ids: @student.team_student_ids
      }
    end

    private

    def coaches
      team_coaches = @student.faculty

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
