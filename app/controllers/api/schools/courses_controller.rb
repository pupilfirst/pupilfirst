module Api
  module Schools
    class CoursesController < SchoolsController
      skip_before_action :verify_authenticity_token
      before_action :authenticate_user!
      before_action :set_course, only: [:students, :create_students]

      def index
        skip_authorization
        render json: scope.to_json
      end

      def students
        students = @course.users.map do |u|
          { name: u.name, email: u.email }
        end
        render json: { students: students }
      end

      def create_students
        form = Students::CreateForm.new(Reform::OpenForm.new)

        response = if form.validate(params.merge({notify: true}))
          student_count = form.save
          { error: nil, studentIds: student_count }
        else
          { error: form.errors.full_messages.join(', ') }
        end

        render json: response
      end

      private

      def set_course
        @course = authorize(scope.find(params[:course_id]),
                            policy_class: ::Schools::CoursePolicy)
      end

      def scope
        @scope ||= policy_scope(Course,
                                policy_scope_class: ::Schools::CoursePolicy::Scope)
      end
    end
  end
end
