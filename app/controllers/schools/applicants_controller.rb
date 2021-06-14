module Schools
  class ApplicantsController < SchoolsController
    # GET /school/courses/:course_id/applicant/:id
    def show
      @course = current_school.courses.find(params[:course_id])
      @applicant =
        authorize(
          @course.applicants.find(params[:id]),
          policy_class: Schools::CourseApplicantPolicy
        )
      render 'schools/courses/applicants'
    end
  end
end
