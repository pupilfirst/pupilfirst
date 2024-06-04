module Beckn::Api
  class OnRatingDataService < Beckn::DataService
    def execute
      return error_response("30004", "Order not found") if student.blank?

      create_rating

      { message: {} }
    end

    def create_rating
      course
        .course_ratings
        .where(user: student.user)
        .first_or_create!(rating: @payload["message"]["value"])
    end

    def course
      @course ||= student.course
    end

    def student
      @student ||= Student.find_by(id: order_data[:student_id])
    end

    def order_id
      @order_id = @payload["message"]["id"]
    end
  end
end
