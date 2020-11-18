module Api
  module Schools
    class CoursesController < SchoolsController
      before_action :set_course, only: [:students, :register_students]
      def index
        authorize(current_school, policy_class: Schools::CoursePolicy)
      end

      def students
        students = @course.users.map do |u|
          { name: u.name, email: u.email }
        end
        render json: students.to_json, status: :ok
      end

      def register_students
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
