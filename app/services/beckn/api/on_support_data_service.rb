module Beckn::Api
  class OnSupportDataService < Beckn::DataService
    def execute
      return error_response("30004", "Order not found") if student.blank?

      { support: { ref_id: order_id, email: school.email } }
    end

    def school
      @school ||= student.school
    end

    def student
      @student ||= find_student_in_bap(order_id)
    end

    def order_id
      @order_id = @payload["message"]["support"]["ref_id"]
    end
  end
end
