module Admissions
  class JoinPresenter < ApplicationPresenter
    def admit?
      Feature.active?(:admissions, view.current_user)
    end

    def link_to_form_text
      admit? ? 'Start Now' : 'Register Interest'
    end
  end
end
