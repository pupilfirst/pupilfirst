module FacultyModule
  class FacultyCardPresenter < ApplicationPresenter
    def initialize(view_context, coach)
      @coach = coach

      super(view_context)
    end

    def can_connect?
      @can_connect ||= view.policy(@coach).connect?
    end

    def show?
      @show ||= view.policy(@coach).show?
    end
  end
end
