module Beckn::Api
  class OnStatusDataService < Beckn::DataService
    def initialize(payload)
      @payload = payload
    end

    def execute
      binding.break

      return error_response("30004", "Order not found") if student.blank?

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
      fullfillment_with_customer(customer).merge(state: state_data)
    end

    def state_descriptor(code, name, updated_at)
      { descriptor: { code: code, name: name }, updated_at: updated_at }
    end

    def state_data
      if student.completed_at?
        state_descriptor("COMPLETED", "Completed", student.completed_at)
      elsif student.timeline_events.exists?
        state_descriptor(
          "IN_PROGRESS",
          "In Progress",
          student.user.last_sign_in_at
        )
      else
        state_descriptor("NOT_STARTED", "Not Started", student.created_at)
      end
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

    def order_data
      @order_data ||= EncryptorService.new.decrypt(order_id)
    end

    def order_id
      @order_id = @payload["message"]["order_id"]
    end
  end
end
