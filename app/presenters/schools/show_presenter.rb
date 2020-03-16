module Schools
  class ShowPresenter < ApplicationPresenter
    # TODO: Probably optimize these queries?
    def school_details
      {
        name: current_school.name,
        students_count: current_school.founders.count,
        coaches_count: current_school.faculty.count
      }
    end

    def course_details
      @course_details ||= begin
        current_school.courses.map do |course|
          {
            id: course.id,
            name: course.name,
            levels_count: course.levels.count,
            students_count: course.founders.count,
            coaches_count: course.faculty.count,
            submissions_count: TimelineEvent.not_auto_verified.where(target: course.targets).count,
            evaluated_submissions_count: TimelineEvent.evaluated_by_faculty.where(target: course.targets).count
          }
        end
      end
    end

    def school_logo_path
      if current_school.logo_on_light_bg.attached?
        current_school.logo_variant("thumb")
      else
        'shared/pupilfirst-icon.svg'
      end
    end
  end
end
