module Beckn::Api
  class OnSearchDataService < Beckn::DataService
    def execute
      {
        message: {
          catalog: {
            descriptor: {
              name: "Course Catalog"
            },
            providers:
              School
                .beckn_enabled
                .joins(:domains)
                .map do |school|
                  @school = school
                  {
                    id: school.id.to_s,
                    descriptor: school_descriptor,
                    categories: [],
                    items:
                      school.courses.beckn_enabled.map do |course|
                        course_descriptor(course)
                      end,
                    fulfillments: [fullfillment_basics]
                  }
                end
          }
        }
      }
    end
  end
end
