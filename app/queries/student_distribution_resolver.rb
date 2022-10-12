class StudentDistributionResolver < ApplicationQuery
  include AuthorizeCoach

  property :course_id
  property :filter_string

  def student_distribution
    students =
      CourseStudentsResolver.new(
        @context,
        { course_id: course_id, filter_string: filter_string }
      ).course_students

    course.levels.map do |level|
      {
        id: level.id,
        number: level.number,
        students_in_level: students.where(level_id: level.id).count,
        unlocked: level.unlocked?,
        filter_name: level.filter_name
      }
    end
  end

  def course
    @course ||= current_school.courses.find_by(id: course_id)
  end
end
