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
        courses: courses,
        student_in_course_ids: course_ids,
      }
    end

    private

    def course_ids
      return [] if current_user.blank?

      current_user.founders.includes(:course).map { |student| student.course.id }
    end

    def courses
      if current_user&.school_admin.present?
        current_school.courses.where(
          id: current_school.users.joins(faculty: :faculty_course_enrollments).distinct(:course_id).select(:course_id),
        )
      else
        current_school.courses.featured
          .or(current_school.courses.where(id: course_ids))
      end.distinct.as_json(only: %w[id name])
    end

    def coaches
      @coaches.map do |coach|
        details = {
          id: coach.id,
          name: coach.name,
          title: coach.title,
          affiliation: coach.affiliation,
          avatar_url: coach.user.avatar_url(variant: :mid),
          about: coach.about,
          course_ids: coach.faculty_course_enrollments.pluck(:course_id),
        }

        details[:connect_link] = coach.connect_link if can_connect_to?(coach)
        details
      end
    end

    def can_connect_to?(coach)
      view.policy(coach).connect?
    end
  end
end
