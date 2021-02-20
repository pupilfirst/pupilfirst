module Validators
  class ArchiveCourse < GraphQL::Schema::Validator
    def validate(_object, _context, value)
      course = Course.find_by(id: value)

      return "Unable to find course with id: #{value}" if course.blank?

      return 'Course is already archived' if course.archived?
    end
  end
end
