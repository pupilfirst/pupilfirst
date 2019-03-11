module Layouts
  class TailwindPresenter < ::ApplicationPresenter
    def meta_description
      @meta_description ||= begin
        if current_school.present?
          SchoolString::Description.for(current_school)
        else
          view.t('presenters.layouts.application.pupil_first_meta_description')
        end
      end
    end
  end
end
