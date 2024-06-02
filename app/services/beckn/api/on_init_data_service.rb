module Beckn::Api
  class OnInitDataService < Beckn::DataService
    def initialize(school, payload)
      @school = school
      @payload = payload
    end

    def execute
      # |30004|Item not found|When BPP is unable to find the item id sent by the BAP|
      return error_response("30004", "Course not found") if course.blank?
      # |30008|Fulfillment unavailable|When BPP is unable to find the fulfillment id sent by the BAP|
      return error_response("30008", "Customer not found") if customer.blank?

      {
        message: {
          order: {
            provider: {
              id: school.id.to_s,
              descriptor: school_descriptor,
              categories: [],
              items: [course_descriptor(course)],
              fulfillments: [fullfillment_with_customer(customer)],
              quote: default_quote,
              billing: billing_details,
              payments: []
            }
          }
        }
      }
    end

    def customer
      @customer = order["fulfillments"].first["customer"]
    end

    def course
      @course ||= school.courses.find_by(id: order["items"].first["id"])
    end

    def order
      @order = @payload["message"]["order"]
    end
  end
end
