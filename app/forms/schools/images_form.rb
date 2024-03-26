module Schools
  class ImagesForm < Reform::Form
    property :logo_on_light_bg,
             virtual: true,
             validates: {
               image: true,
               file_size: {
                 less_than: 2.megabytes
               }
             },
             allow_nil: true
    property :logo_on_dark_bg,
             virtual: true,
             validates: {
               image: true,
               file_size: {
                 less_than: 2.megabytes
               }
             },
             allow_nil: true
    property :cover_image,
             virtual: true,
             validates: {
               image: true,
               file_size: {
                 less_than: 2.megabytes
               }
             },
             allow_nil: true
    property :icon_on_light_bg,
             virtual: true,
             validates: {
               image: true,
               file_size: {
                 less_than: 2.megabytes
               }
             },
             allow_nil: true
    property :icon_on_dark_bg,
             virtual: true,
             validates: {
               image: true,
               file_size: {
                 less_than: 2.megabytes
               }
             },
             allow_nil: true

    def save
      %i[
        logo_on_light_bg
        logo_on_dark_bg
        cover_image
        icon_on_light_bg
        icon_on_dark_bg
      ].each do |image|
        model.public_send(image).attach(send(image)) if send(image).present?
      end
    end
  end
end
