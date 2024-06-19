module Beckn::Api
  class OnSearchDataService < Beckn::DataService
    def execute
      {
        message: {
          catalog: {
            descriptor: {
              name: "Course Catalog",
            },
            providers:
              schools.map do |school|
                @school = school
                {
                  id: school.id.to_s,
                  descriptor: school_descriptor,
                  categories: school_categories,
                  items:
                    school.courses.beckn_enabled.map do |course|
                      course_descriptor(course)
                    end,
                  fulfillments: [fullfillment_basics],
                }
              end,
          },
        },
      }
    end

    def schools
      item_name =
        @payload.dig("message", "intent", "item", "descriptor", "name")
      provider_id = @payload.dig("message", "intent", "provider", "id")
      # Default scope
      scope = School.beckn_enabled
      # When provider is present
      scope = scope.where(id: provider_id) if provider_id.present?
      # When a discriptor is present join courses and seraach by course name
      scope =
        scope.joins(:courses).where(
          "courses.name ILIKE ?",
          "%#{item_name}%",
        ) if item_name.present?
      # Return the scope
      scope
    end
  end
end
