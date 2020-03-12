module Schools
  class CoursesController < SchoolsController
    layout 'school'

    def index
      authorize(current_school, policy_class: Schools::CoursePolicy)
    end

    # POST /courses/id/attach_images
    def attach_images
      course = authorize(scope.find(params[:id]), policy_class: Schools::CoursePolicy)
      @form = Schools::Courses::UpdateImagesForm.new(course)

      if @form.validate(params)
        @form.save
        render json: { thumbnail_url: course.thumbnail_url, cover_url: course.cover_url, error: nil }
      else
        render json: { thumbnail_url: nil, cover_url: nil, error: @form.errors.full_messages.join(', ') }
      end
    end

    # GET /courses/:id/curriculum
    def curriculum
      course = scope.where(id: params[:id]).includes(:evaluation_criteria, :levels, :target_groups, :targets).first
      @course = authorize(course, policy_class: Schools::CoursePolicy)
    end

    # POST /school/courses/:course_id/delete_coach_enrollment
    def delete_coach_enrollment
      coach = current_school.faculty.find(params[:coach_id])
      course = authorize(scope.find(params[:course_id]), policy_class: Schools::CoursePolicy)

      ::Courses::UnassignReviewerService.new(course).unassign(coach)

      render json: { coach_id: coach.id.to_s, error: nil }
    end

    def update_coach_enrollments
      course = authorize(scope.find(params[:course_id]), policy_class: Schools::CoursePolicy)
      coaches = current_school.faculty.where(id: params[:coach_ids]).includes(:school)

      coaches.each do |coach|
        ::Courses::AssignReviewerService.new(course).assign(coach)
      end

      course_coaches = coaches.map do |coach|
        {
          id: coach.id.to_s,
          name: coach.name,
          title: coach.title,
          email: coach.email,
          avatarUrl: coach.user.avatar_url(variant: :thumb)
        }
      end

      render json: { course_coaches: course_coaches, error: nil }
    end

    # GET /school/courses/:course_id/students
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
      authorize(scope.find(params[:course_id]), policy_class: Schools::CoursePolicy)

      form = Schools::Founders::CreateForm.new(Reform::OpenForm.new)

      response = if form.validate(params)
        student_count = form.save
        { error: nil, studentCount: student_count }
      else
        { error: form.errors.full_messages.join(', ') }
      end

      render json: response
    end

    # POST /school/courses/:course_id/mark_teams_active?team_ids[]=
    def mark_teams_active
      course = authorize(scope.find(params[:course_id]), policy_class: Schools::CoursePolicy)

      Startup.transaction do
        course.startups.where(id: params[:team_ids]).each do |startup|
          startup.update!(access_ends_at: nil, dropped_out_at: nil)
        end

        render json: { message: 'Teams marked active successfully!', error: nil }
      end
    end

    # GET /school/courses/:id/exports
    def exports
      @course = authorize(scope.find(params[:id]), policy_class: Schools::CoursePolicy)
    end

    # GET /school/courses/:id/authors
    def authors
      @course = authorize(scope.find(params[:id]), policy_class: Schools::CoursePolicy)
    end

    # GET /school/courses/:id/evaluation_criteria
    def evaluation_criteria
      @course = authorize(scope.find(params[:id]), policy_class: Schools::CoursePolicy)
    end

    private

    def scope
      @scope ||= policy_scope(Course, policy_scope_class: Schools::CoursePolicy::Scope)
    end
  end
end
