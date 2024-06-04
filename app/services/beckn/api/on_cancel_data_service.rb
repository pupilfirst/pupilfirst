module Beckn::Api
  class OnCancelDataService < Beckn::DataService
    def execute
      return error_response("30004", "Order not found") if student.blank?

      Students::MarkAsDroppedOutService.new(student, student.user).execute

      {
        message: {
          order: {
            id: order_id,
            provider: {
              id: school.id.to_s,
              descriptor: school_descriptor,
              categories: []
            },
            items: [course_descriptor_with_stops(student)],
            fulfillments: [fullfillment_with_state],
            quote: default_quote,
            billing: billing_details,
            payments: []
          }
        }
      }
    end

    def customer
      @customer ||= {
        person: {
          name: student.user.name
        },
        contact: {
          email: student.user.email
        }
      }
    end

    def fullfillment_with_state
      fullfillment_with_customer(customer).merge(
        state:
          state_descriptor(
            "course-cancelled",
            "Course has been cancelled",
            student.dropped_out_at
          )
      )
    end

    def course
      @course ||= student.course
    end

    def school
      @school ||= student.school
    end

    def student
      @student ||= Student.find_by(id: order_data[:student_id])
    end

    def order_id
      @order_id = @payload["message"]["order_id"]
    end
  end
end
