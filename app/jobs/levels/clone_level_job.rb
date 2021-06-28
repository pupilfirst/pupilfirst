module Levels
  class CloneLevelJob < ApplicationJob
    queue_as :low_priority

    def perform(source_level_id, target_course_id)
      level = Level.find(source_level_id)
      course = Course.find(target_course_id)
      ::Levels::CloneService.new.clone(level, course)
    end
  end
end
