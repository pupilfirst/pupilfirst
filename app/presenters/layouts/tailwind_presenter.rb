module Layouts
  class TailwindPresenter < ::ApplicationPresenter
    def meta_description
      @meta_description ||= SchoolString::Description.for(current_school)
    end

    def flash_messages
      view.flash.map do |type, message|
        {
          type: type,
          message: message
        }
      end.to_json
    end
  end
end
