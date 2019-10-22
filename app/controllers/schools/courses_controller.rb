module Schools
  class CoursesController < SchoolsController
    include CamelizeKeys
    include StringifyIds

    layout 'school'

    def index
      authorize(current_school, policy_class: Schools::CoursePolicy)
    end

    # GET /courses/:id/curriculum
    def curriculum
      course = scope.where(id: params[:id]).includes([:evaluation_criteria, :levels, :target_groups, targets: [:evaluation_criteria, :prerequisite_targets, :resources, quiz: { quiz_questions: %I[answer_options correct_answer] }]]).first
      @course = authorize(course, policy_class: Schools::CoursePolicy)
    end

    # POST /school/courses/:course_id/delete_coach_enrollment
    def delete_coach_enrollment
      coach = current_school.faculty.find(params[:coach_id])
      course = authorize(scope.find(params[:course_id]), policy_class: Schools::CoursePolicy)

      ::Courses::UnassignReviewerService.new(course).unassign(coach)

      render json: { coach_id: coach.id, error: nil }
    end

    def update_coach_enrollments
      course = authorize(scope.find(params[:course_id]), policy_class: Schools::CoursePolicy)
      coaches = current_school.faculty.where(id: params[:coach_ids]).includes(:school)

      coaches.each do |coach|
        ::Courses::AssignReviewerService.new(course).assign(coach)
      end

      render json: { coach_ids: course.faculty.pluck(:id), error: nil }
    end

    def students
      @course = authorize(scope.find(params[:course_id]), policy_class: Schools::CoursePolicy)
    end

    def inactive_students
      @course = authorize(scope.find(params[:course_id]), policy_class: Schools::CoursePolicy)

      inactive_teams = if params[:search].present?
        ::Courses::InactiveTeamsSearchService.new(@course).find_teams(params[:search].to_s)
      else
        Startup.joins(:course).inactive.where(courses: { id: @course }).to_a
      end

      @teams = Kaminari.paginate_array(inactive_teams).page(params[:page]).per(20)
    end

    # POST /school/courses/:course_id/students?students[]=
    def create_students
      course = authorize(scope.find(params[:course_id]), policy_class: Schools::CoursePolicy)

      form = Schools::Founders::CreateForm.new(Reform::OpenForm.new)

      response = if form.validate(params)
        student_count = form.save
        presenter = Schools::Founders::IndexPresenter.new(view_context, course)

        {
          teams: presenter.teams,
          students: presenter.students,
          error: nil,
          studentCount: student_count
        }
      else
        { error: form.errors.full_messages.join(', ') }
      end

      render json: camelize_keys(stringify_ids(response))
    end

    # POST /school/courses/:course_id/mark_teams_active?team_ids[]=
    def mark_teams_active
      course = authorize(scope.find(params[:course_id]), policy_class: Schools::CoursePolicy)

      Startup.transaction do
        course.startups.where(id: params[:team_ids]).each do |startup|
          startup.update!(access_ends_at: nil)
        end

        render json: { message: 'Teams marked active successfully!', error: nil }
      end
    end

    # GET /school/courses/:id/exports
    def exports
      @course = authorize(scope.find(params[:id]), policy_class: Schools::CoursePolicy)
    end

    private

    def scope
      @scope ||= policy_scope(Course, policy_scope_class: Schools::CoursePolicy::Scope)
    end
  end
end
