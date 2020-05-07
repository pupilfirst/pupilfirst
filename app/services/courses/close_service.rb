module Courses
  class CloseService
    def initialize(course)
      @course = course
    end

    def close
      @course.update!(ends_at: Time.zone.now)
    end
  end
end
