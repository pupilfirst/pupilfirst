module Beckn::Api
  class OnSelectDataService < Beckn::DataService
    def execute
      # |30001|Provider not found|When BPP is unable to find the provider id sent by the BAP|
      return error_response("30001", "School not found") if school.blank?
      # |30004|Item not found|When BPP is unable to find the item id sent by the BAP|
      return error_response("30004", "Course not found") if course.blank?

      {
        message: {
          order: {
            provider: {
              id: school.id.to_s,
              descriptor: school_descriptor,
              categories: []
            },
            items: [course_descriptor(course)],
            fulfillments: [fullfillment_basics],
            quote: default_quote
          }
        }
      }
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
