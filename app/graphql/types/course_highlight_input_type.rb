module Types
  class CourseHighlightInputType < Types::BaseInputObject
    def self.allowed_icons
      %w[
        plus-circle-solid
        plus-circle-regular
        plus-circle-light
        lamp-solid
        check-light
        times-light
        badge-check-solid
        badge-check-regular
        badge-check-light
        writing-pad-solid
        eye-solid
        users-solid
        users-regular
        users-light
        ellipsis-h-solid
        ellipsis-h-regular
        ellipsis-h-light
        check-square-alt-solid
        check-square-alt-regular
        check-square-alt-light
        comment-alt-solid
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
