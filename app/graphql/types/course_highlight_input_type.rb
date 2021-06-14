module Types
  class CourseHighlightInputType < Types::BaseInputObject
    def self.allowed_icons
      %w[
        book-open-solid
        book-open-light
        lamp-solid
        badge-check-solid
        writing-pad-solid
        eye-solid
        users-solid
        certificate-regular
        briefcase-solid
        globe-light
        signal-fill-solid
        signal-2-light
        signal-1-light
        academic-cap-solid
        award-solid
      ]
    end

    argument :icon,
             String,
             required: true,
             validates: {
               inclusion: {
                 in: allowed_icons
               }
             }
    argument :title,
             String,
             required: true,
             validates: {
               length: {
                 minimum: 1,
                 maximum: 150
               }
             }
    argument :description,
             String,
             required: true,
             validates: {
               length: {
                 minimum: 1,
                 maximum: 250
               }
             }
  end
end
