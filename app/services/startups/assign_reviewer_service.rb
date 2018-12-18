module Startups
  class AssignReviewerService
    def initialize(startup)
      @startup = startup
    end

    def assign(faculty)
      return if faculty.startups.where(id: @startup).exists?
      return if faculty.courses.where(id: @startup.level.course).exists?

      FacultyStartupEnrollment.create!(
        safe_to_create: true,
        faculty: faculty,
        startup: @startup
      )
    end
  end
end
