module FacultyModule
  class IndexPresenter < ApplicationPresenter
    def initialize(coaches, view_context)
      @coaches = coaches
      super(view_context)
    end

    def props
      {
        subheading: SchoolString::CoachesIndexSubheading.for(current_school),
        coaches: coaches,
        student_in_course_ids: course_ids
      }
    end

    private

    def course_ids
      return [] if current_user.blank?

      current_user.founders.includes(:course).map { |student| student.course.id }
    end

    def coaches
      @coaches.map do |coach|
        {
          id: coach.id,
          name: coach.name,
          title: coach.title,
          affiliation: coach.affiliation,
          avatar_url: coach.user.avatar_url(variant: :mid),
          about: coach.about,
          connect_link: coach.connect_link,
          course_ids: coach.faculty_course_enrollments.pluck(:course_id)
        }
      end
    end

    def can_connect?
      @can_connect ||= view.policy(@coach).connect?
    end
  end
end
