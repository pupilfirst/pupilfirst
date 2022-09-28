class FacultyController < ApplicationController
  # GET /coaches
  def index
    @coaches =
      policy_scope(Faculty).includes(
        :faculty_cohort_enrollments,
        user: {
          avatar_attachment: :blob
        }
      )

    raise_not_found unless @coaches.exists?

    render 'index', layout: 'student'
  end
end
