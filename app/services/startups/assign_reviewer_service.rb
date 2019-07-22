module Startups
  class AssignReviewerService
    def initialize(startup)
      @startup = startup
    end

    def assign(faculty_ids)
      @faculty_to_assign = @startup.school.faculty.where(id: faculty_ids)

      raise 'Faculty must in same school as team' if @faculty_to_assign.count != [faculty_ids].flatten.count

      FacultyStartupEnrollment.transaction do
        FacultyStartupEnrollment.where(startup: @startup).destroy_all

        @faculty_to_assign.each do |faculty|
          next if faculty.courses.where(id: @startup.level.course).exists?

          FacultyStartupEnrollment.create!(
            safe_to_create: true,
            faculty: faculty,
            startup: @startup
          )
        end
      end
    end
  end
end
