module Layouts
  class StudentCoursePresenter < ::ApplicationPresenter
    private

    def props
      {
        authenticity_token: view.form_authenticity_token
      }
    end
  end
end
