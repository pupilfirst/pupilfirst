module Targets
  class ShowPresenter < Courses::ShowPresenter
    def initialize(view_context, target)
      @target = target
      super(view_context, target.course)
    end

    private

    def props
      super.merge(selected_target_id: @target.id)
    end
  end
end
