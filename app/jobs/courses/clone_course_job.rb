module Courses
  class CloneCourseJob < ApplicationJob
    queue_as :low_priority

    def perform(source_course_id)
      course = Course.find(source_course_id)
      new_name = I18n.t('jobs.courses.clone_course.new_name', name: course.name)
      ::Courses::CloneService.new(course).clone(new_name, course.school)
    end
  end
end
