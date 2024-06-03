module Beckn::Api
  class OnConfirmDataService < Beckn::DataService
    def initialize(payload)
      @payload = payload
    end

    def execute
      # |30001|Provider not found|When BPP is unable to find the provider id sent by the BAP|
      return error_response("30001", "School not found") if school.blank?
      # |30004|Item not found|When BPP is unable to find the item id sent by the BAP|
      return error_response("30004", "Course not found") if course.blank?
      # |30008|Fulfillment unavailable|When BPP is unable to find the fulfillment id sent by the BAP|
      return error_response("30008", "Customer not found") if customer.blank?

      {
        message: {
          order: {
            id: order_id,
            provider: {
              id: school.id.to_s,
              descriptor: school_descriptor,
              categories: [],
              items: [course_descriptor_with_stops(student)],
              fulfillments: [fullfillment_with_customer(customer)],
              quote: default_quote,
              billing: billing_details,
              payments: []
            }
          }
        }
      }
    end

    def order_id
      EncryptorService.new.encrypt(
        {
          bap_id: @payload["context"]["bap_id"],
          transaction_id: @payload["context"]["transaction_id"],
          student_id: student.id
        }
      )
    end

    def student
      @student ||=
        begin
          return unless customer_present?

          students = [
            OpenStruct.new(
              name: customer["person"]["name"],
              email: customer["contact"]["email"]
            )
          ]

          # Add student to default cohort
          Cohorts::AddStudentsService.new(
            course.default_cohort,
            notify: false
          ).add(students)

          course
            .students
            .joins(:user)
            .find_by(user: { email: customer["contact"]["email"] })
        end
    end

    def customer_present?
      customer.present? && customer["person"]["name"].present? &&
        customer["contact"]["email"].present?
    end

    def customer
      @customer = order["fulfillments"].first["customer"]
    end

    def course
      @course ||=
        school.courses.beckn_enabled.find_by(id: order["items"].first["id"])
    end

    def school
      @school ||= School.beckn_enabled.find_by(id: order["provider"]["id"])
    end

    def order
      @order = @payload["message"]["order"]
    end
  end
end
