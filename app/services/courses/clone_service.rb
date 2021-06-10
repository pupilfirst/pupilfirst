module Courses
  # Creates a clone of a service with a new name.
  #
  # It copies all levels, target groups and targets, but leaves out student infomation and submissions, creating a fresh
  # course ready for modification and use.
  class CloneService
    def initialize(course, levels_clone_service: Levels::CloneService.new)
      @course = course
      @levels_clone_service = levels_clone_service
      @target_id_translation = {}
    end

    def clone(new_name, school)
      Course.transaction do
        Course
          .create!(
            name: new_name,
            description: @course.description,
            school: school,
            progression_behavior: @course.progression_behavior,
            progression_limit: @course.progression_limit
          )
          .tap do |new_course|
            @course.levels.order(:number).each do |level|
              @levels_clone_service.clone(level, new_course)
            end
            if @course.cover.attached?
              new_course.cover.attach(@course.cover.blob)
            end
            if @course.thumbnail.attached?
              new_course.thumbnail.attach(@course.thumbnail.blob)
            end
          end
      end
    end
  end
end
