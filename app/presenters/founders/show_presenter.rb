module Founders
  class ShowPresenter < ApplicationPresenter
    def initialize(view_context, founder)
      @founder = founder
      super(view_context)
    end

    def course_name
      @founder.startup.course.name
    end

    def incomplete_profile?
      @founder.exited_on.nil? && @founder.profile_completion_percentage < 100
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
  end
end
