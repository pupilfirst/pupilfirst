module Schools
  class CoursesController < SchoolsController
    layout 'school'

    def index
      authorize current_school
    end

    # POST /school/courses/:course_id/delete_coach_enrollment
    def delete_coach_enrollment
      coach = Faculty.find(params[:coach_id])
      course = Course.find(params[:course_id])

      authorize(course, policy_class: Schools::CoursePolicy)
      ::Courses::UnassignReviewerService.new(course).unassign(coach)
      render json: { coach_id: coach.id, error: nil }
    end

    def update_coach_enrollments
      course = courses.find(params[:course_id])
      @course = authorize(course, policy_class: Schools::CoursePolicy)
      enrolled_coach_ids = params[:coach_ids]
      coaches = current_school.faculty.where(id: enrolled_coach_ids).includes(:school)
      coaches.each do |coach|
        ::Courses::AssignReviewerService.new(course).assign(coach)
      end
      render json: { coach_ids: @course.faculty.pluck(:id), error: nil }
    end
  end
end
