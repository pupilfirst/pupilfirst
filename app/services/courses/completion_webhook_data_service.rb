module Courses
  class CompletionWebhookDataService
    def initialize(course, user)
      @course = course
      @user = user
    end

    def data
      {
        course_id: @course.id,
        course_name: @course.name,
        student_name: @user.name,
        student_email: @user.email
      }
    end
  end
end
