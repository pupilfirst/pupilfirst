module Startups
  class UnassignReviewerService
    def initialize(startup)
      @startup = startup
    end

    def unassign(faculty)
      @startup.faculty_startup_enrollments.find_by(faculty: faculty)&.destroy!
    end
  end
end
