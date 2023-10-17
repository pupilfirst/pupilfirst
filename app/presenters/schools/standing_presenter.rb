module Schools
  class StandingPresenter < ApplicationPresenter
    def initialize(view_context, school)
      super(view_context)

      @school = school
    end

    def standing_enabled?
      @school.configuration["enable_standing"]
    end
  end
end
