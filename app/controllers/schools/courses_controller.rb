module Schools
  class CoursesController < SchoolsController
    include CamelizeKeys
    include StringifyIds

    layout "school"

    # POST /courses/id/attach_images
    def attach_images
      course =
        authorize(scope.find(params[:id]), policy_class: Schools::CoursePolicy)
      @form = Schools::Courses::UpdateImagesForm.new(course)

      if @form.validate(params)
        @form.save
        render json: {
                 thumbnail_url: course.thumbnail_url,
                 cover_url: course.cover_url,
                 error: nil
               }
      else
        render json: {
                 thumbnail_url: nil,
                 cover_url: nil,
                 error: @form.errors.full_messages.join(", ")
               }
      end
    end

    # GET /courses/:id/curriculum
    def curriculum
      course =
        scope.includes(
          :evaluation_criteria,
          :levels,
          :target_groups,
          :targets
        ).find(params[:id])

      @course = authorize(course, policy_class: Schools::CoursePolicy)
    end

    # GET /courses/:id/calendar_events
    def calendar_events
      @course =
        authorize(scope.find(params[:id]), policy_class: Schools::CoursePolicy)
      @presenter =
        Schools::Courses::CalendarsPresenter.new(view_context, @course, params)
    end

    # GET /courses/:id/calendar_month_data
    def calendar_month_data
      @course =
        authorize(scope.find(params[:id]), policy_class: Schools::CoursePolicy)
      @presenter =
        Schools::Courses::CalendarsPresenter.new(view_context, @course, params)
      render json: @presenter.month_data
    end

    # POST /school/courses/:course_id/delete_coach_enrollment
    def delete_coach_enrollment
      coach = current_school.faculty.find(params[:coach_id])
      course =
        authorize(
          scope.find(params[:course_id]),
          policy_class: Schools::CoursePolicy
        )

      ::Cohorts::UnassignReviewerService.new(course).unassign(coach)

      render json: { coach_id: coach.id.to_s, error: nil }
    end

    def update_coach_enrollments
      course =
        authorize(
          scope.find(params[:course_id]),
          policy_class: Schools::CoursePolicy
        )
      coaches =
        current_school.faculty.where(id: params[:coach_ids]).includes(:school)

      cohorts = course.cohorts.where(id: params[:cohort_ids])

      coaches.each do |coach|
        ::Cohorts::ManageReviewerService.new(
          course,
          cohorts,
          notify: true
        ).assign(coach)
      end

      course_coaches =
        coaches.map do |coach|
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
      @course =
        authorize(
          scope.find(params[:course_id]),
          policy_class: Schools::CoursePolicy
        )
    end

    # GET /school/courses/:id/applicants
    def applicants
      @course =
        authorize(scope.find(params[:id]), policy_class: Schools::CoursePolicy)
    end

    # GET /school/courses/:id/exports
    def exports
      @course =
        authorize(scope.find(params[:id]), policy_class: Schools::CoursePolicy)
    end

    # GET /school/courses/:id/authors
    def authors
      @course =
        authorize(scope.find(params[:id]), policy_class: Schools::CoursePolicy)
    end

    # GET /school/courses/:id/certificates
    def certificates
      @course =
        authorize(scope.find(params[:id]), policy_class: Schools::CoursePolicy)
    end

    # POST /school/courses/:id/certificates
    def create_certificate
      @course =
        authorize(scope.find(params[:id]), policy_class: Schools::CoursePolicy)

      form = ::Courses::CreateCertificateForm.new(@course)

      props =
        if form.validate(params)
          scope = Certificate.where(id: form.save.id)
          ActiveRecord::Precounter.new(scope).precount(:issued_certificates)

          {
            error: nil,
            certificate:
              Schools::Courses::CertificatesPresenter.certificate_details(
                scope.first
              )
          }
        else
          { error: form.errors.full_messages.join(", ") }
        end

      render json: camelize_keys(stringify_ids(props))
    end

    # GET /school/courses/:id/evaluation_criteria
    def evaluation_criteria
      @course =
        authorize(scope.find(params[:id]), policy_class: Schools::CoursePolicy)
    end

    # GET /school/courses/:id/assignments
    def assignments
      @course =
        authorize(scope.find(params[:id]), policy_class: Schools::CoursePolicy)
      @milestones =
        @course
          .targets
          .includes(:assignments)
          .live
          .milestone
          .order("assignments.milestone_number asc")
          .page(params[:page])
          .per(20)
      @page_no = params[:page].presence || 1
      @have_gaps = gap?(@milestones.pluck("assignments.milestone_number"))
    end

    private

    def gap?(numbers)
      remains = (1..numbers.length).to_a - numbers
      remains.present?
    end

    def scope
      @scope ||=
        policy_scope(Course, policy_scope_class: Schools::CoursePolicy::Scope)
    end
  end
end
