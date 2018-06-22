module Coaches
  class DashboardPresenter < ApplicationPresenter
    def react_props
      {
        coach: { name: current_coach.name, id: current_coach.id }
      }
    end

    private

    def current_coach
      @current_coach ||= view.current_coach
    end
  end
end
