module Schools
  class StandingPresenter < ApplicationPresenter
    def initialize(view_context, school)
      super(view_context)

      @school = school
    end

    def standing_enabled?
      Schools::Configuration.new(@school).standing_enabled?
    end

    def standings
      @standings ||= @school.standings.live.order(:created_at)
    end

    def standing_log_count_for_each_unarchived_standing
      UserStanding
        .where(standing: standings, archived_at: nil)
        .group(:standing_id)
        .count
    end

    def school_has_code_of_conduct?
      SchoolString::CodeOfConduct.saved?(@school)
    end
  end
end
