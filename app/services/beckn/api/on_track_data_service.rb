module Beckn::Api
  class OnTrackDataService < Beckn::DataService
    def execute
      return error_response("30004", "Order not found") if student.blank?
      # Initialize the school variable for url generation helper
      @school = student.school

      {
        message: {
          tracking: {
            id: order_id,
            url: public_url("report_course_path", course.id),
            status: "active"
          }
        }
      }
    end

    def course
      @course ||= student.course
    end

    def student
      @student ||= find_student_in_bap(order_id)
    end

    def order_id
      @order_id = @payload["message"]["order_id"]
    end
  end
end
