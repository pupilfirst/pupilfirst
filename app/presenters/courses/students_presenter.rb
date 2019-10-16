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
        authenticity_token: view.form_authenticity_token,
        levels: levels,
        course: course_details,
        students: student_details,
        teams: team_details
      }
    end

    def current_coach_details
      {
        name: current_user.name,
        avatar_url: current_user.image_or_avatar_url,
        title: current_user.title
      }
    end

    def levels
      @course.levels.map do |level|
        level.attributes.slice('id', 'name', 'number')
      end
    end

    def course_details
      { id: @course.id, total_targets: @course.targets.count }
    end

    def students
      @students ||= Founder.where(startup_id: current_coach.reviewable_startups(@course))
    end

    def student_details
      students.map do |student|
        {
          id: student.id,
          name: student.name,
          team_id: student.startup_id
        }
      end
    end

    def team_details
      Startup.where(id: students.select(:startup_id).distinct).map do |startup|
        startup.attributes.slice('id', 'name', 'level_id')
      end
    end
  end
end
