module Api
  module Schools
    class CoursesController < SchoolsController
      skip_before_action :verify_authenticity_token
      before_action :set_course, only: [:students, :create_students]
      def index
        authorize(current_school, policy_class: Schools::CoursePolicy)
      end

      def students
        students = @course.users.map do |u|
          { name: u.name, email: u.email }
        end
        render json: { students: students.to_json }
      end

      def create_students 
        form = ::Schools::Founders::CreateForm.new(Reform::OpenForm.new)

        response = if form.validate(params)
          student_count = form.save
          { error: nil, studentCount: student_count }
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
