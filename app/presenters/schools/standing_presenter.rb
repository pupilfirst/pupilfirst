module Schools
  class StandingPresenter < ApplicationPresenter
    def initialize(view_context, school)
      super(view_context)

      @school = school
    end

    def standing_enabled?
      @school.configuration["enable_standing"]
    end

    def standings
      @standings ||= @school.standings.order(:id)
    end

    def school_has_code_of_conduct?
      SchoolString::CodeOfConduct.saved?(@school)
    end
  end
end
