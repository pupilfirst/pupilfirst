module Schools
  class ShowPresenter < ApplicationPresenter
    # TODO: Probably optimize these queries?
    def school_details
      {
        name: school.name,
        students_count: school.founders.count,
        coaches_count: school.faculty.count
      }
    end

    def course_details
      @course_details ||= begin
        school.courses.map do |course|
          {
            name: course.name,
            levels_count: course.levels.count,
            students_count: course.founders.count,
            coaches_count: course.faculty.count + FacultyStartupEnrollment.where(startup: course.startups).count,
            submissions_count: TimelineEvent.not_auto_verified.where(target: course.targets).count,
            evaluated_submissions_count: TimelineEvent.evaluated_by_faculty.where(target: course.targets).count
          }
        end
      end
    end

    private

    def school
      view.current_school
    end
  end
end
