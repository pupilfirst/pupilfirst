module Beckn::Api
  class OnUpdateDataService < Beckn::DataService
    def execute
      return error_response("30004", "Order not found") if student.blank?

      student.user.update!(name: new_name) if new_name.present?

      {
        message: {
          order: {
            id: order_id,
            provider: {
              id: school.id.to_s,
              descriptor: school_descriptor,
              categories: [],
            },
            items: [course_descriptor(course)],
            fulfillments: [fullfillment_with_state],
            quote: default_quote,
            billing: billing_details,
            payments: [],
          },
        },
      }
    end

    def new_name
      order_input["items"].first["fulfillments"].first["customer"]["person"][
        "name"
      ]
    end

    def course
      @course ||= student.course
    end

    def school
      @school ||= student.school
    end

    def student
      @student ||= find_student_in_bap(order_id)
    end

    def order_input
      @order_input = @payload["message"]["order"]
    end

    def order_id
      @order_id = order_input["id"]
    end
  end
end
