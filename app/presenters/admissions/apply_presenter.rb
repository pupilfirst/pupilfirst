module Admissions
  class ApplyPresenter < ApplicationPresenter
    def admit?
      Feature.active?(:admissions, view.current_user)
    end

    def link_to_form_text
      admit? ? 'Apply Now' : 'Register Interest'
    end
  end
end
