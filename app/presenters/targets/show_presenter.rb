module Targets
  class ShowPresenter < Courses::CurriculumPresenter
    def initialize(view_context, target)
      @target = target
      super(view_context, target.course)
    end
  end
end
