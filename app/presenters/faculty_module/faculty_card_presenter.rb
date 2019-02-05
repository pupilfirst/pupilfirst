module FacultyModule
  class FacultyCardPresenter < ApplicationPresenter
    def initialize(view_context, coach)
      @coach = coach

      super(view_context)
    end

    def can_connect?
      view.policy(@coach).connect?
    end

    def show_href
      view.policy(@coach).show? ? view.coach_url(@coach) : '#'
    end
  end
end
