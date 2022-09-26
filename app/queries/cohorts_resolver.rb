class CohortsResolver < ApplicationQuery
  include AuthorizeSchoolAdmin
  include FilterUtils

  property :course_id
  property :filter_string

  def cohorts
    scope = course.cohorts

    case filter[:status]&.downcase
    when 'active'
      scope = scope.active
    when 'ended'
      scope = scope.ended
    else
      scope
    end

    scope = scope.where('name ILIKE ?', "%#{filter[:name]}%") if filter[:name]
      .present?

    if filter[:sort_by].present?
      scope.order("#{sort_by_string}")
    else
      scope.order('created_at DESC')
    end
  end

  private

  def sort_by_string
    case filter[:sort_by]
    when 'Name'
      'name ASC'
    when 'First Created'
      'created_at ASC'
    when 'Last Created'
      'created_at DESC'
    when 'Last Ending'
      'ends_at DESC'
    else
      raise "#{filter[:sort_by]} is not a valid sort criterion"
    end
  end

  def resource_school
    course&.school
  end

  def course
    @course ||= current_school.courses.find_by(id: course_id)
  end
end
