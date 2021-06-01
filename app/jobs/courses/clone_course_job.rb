module Courses
  class CloneCourseJob < ApplicationJob
    queue_as :low_priority

    def perform(source_course_id)
      course = Course.find(source_course_id)
      new_name = [course.name, "copy"].join(" - ")
      ::Courses::CloneService.new(course).clone(new_name, course.school)
    end
  end
end
