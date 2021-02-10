module Api
  module Schools
    class CoursesController < ApplicationController
      skip_before_action :verify_authenticity_token
      after_action :verify_authorized, except: :index
      after_action :verify_policy_scoped, only: :index
      before_action :authenticate_user!
      before_action :set_course, only: [:students, :create_students]

      def index
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

        if form.validate(students_params.merge({notify: true}))
          student_count = form.save
          render json: { error: nil, studentIds: student_count }, status: :created
        else
          render json: { error: form.errors.full_messages.join(', ') }, status: :bad_request
        end
      end

      private

      def students_params
        stds = params.require(:students).map { |p| p.permit(:name, :email) }
        {course_id: @course.id, students: stds }
      end

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
