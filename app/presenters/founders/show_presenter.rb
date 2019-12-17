module Founders
  class ShowPresenter < ApplicationPresenter
    def initialize(view_context, founder)
      @founder = founder
      super(view_context)
    end

    def course_name
      team.course.name
    end

    def incomplete_profile?
      team.dropped_out_at.nil? && @founder.profile_completion_percentage < 100
    end

    def public_faculty
      @founder.faculty.where(public: true)
    end

    def faculty_display_text
      if public_faculty.count > 1
        "Coaches"
      else
        "Coach"
      end
    end

    def team
      @team ||= @founder.startup
    end
  end
end
