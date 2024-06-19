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
        .first_or_create!(rating: rating_input["value"])
    end

    def course
      @course ||= student.course
    end

    def student
      @student ||= find_student_in_bap(order_id)
    end

    def rating_input
      @payload["message"]["ratings"].first
    end

    def order_id
      @order_id = rating_input["id"]
    end
  end
end
