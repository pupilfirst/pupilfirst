class CourseResourceInfoResolver < ApplicationQuery
  include AuthorizeReviewer

  property :course_id
  property :resources

  def course_resource_info
    resources.map do |resource|
      case resource
      when 'Level'
        resource_shape(resource, course.levels.map(&:filter_name))
      when 'Cohort'
        resource_shape(resource, course.cohorts.map { |l| "#{l.id};#{l.name}" })
      when 'StudentTag'
        resource_shape(resource, course.student_tags)
      when 'UserTag'
        resource_shape(resource, course.user_tags)
      when 'Coach'
        resource_shape(resource, course.faculty.map { |l| "#{l.id};#{l.name}" })
      else
        raise "Unknown resource: #{resource}"
      end
    end
  end

  private

  def resource_shape(resource, values)
    { resource: resource, values: values }
  end

  def course
    @course ||= current_school.courses.find_by(id: course_id)
  end

  def resource_school
    course&.school
  end
end
