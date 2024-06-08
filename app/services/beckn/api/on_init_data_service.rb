module Beckn::Api
  class OnInitDataService < Beckn::DataService
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
            provider: {
              id: school.id.to_s,
              descriptor: school_descriptor,
              categories: []
            },
            items: [course_descriptor(course)],
            fulfillments: [fullfillment_with_customer(customer)],
            quote: default_quote,
            billing: billing_details,
            payments: []
          }
        }
      }
    end

    def customer
      @customer = order["fulfillments"].first["customer"]
    end

    def course
      @course ||=
        school.courses.beckn_enabled.find_by(id: order["items"].first["id"])
    end

    def order
      @order = @payload["message"]["order"]
    end

    def school
      @school ||= School.beckn_enabled.find_by(id: order["provider"]["id"])
    end
  end
end
