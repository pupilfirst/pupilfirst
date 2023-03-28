class TeamsResolver < ApplicationQuery
  include AuthorizeSchoolAdmin
  include FilterUtils

  property :course_id
  property :filter_string

  def teams
    scope = course.teams

    case filter[:status]&.downcase
    when 'active'
      scope = scope.active
    when 'inactive'
      scope = scope.inactive
    else
      scope
    end

    scope = scope.where(cohort_id: cohort.id) if cohort.present?
    scope = scope.where('teams.name ILIKE ?', "%#{filter[:name]}%") if filter[
      :name
    ].present?

    if filter[:sort_by].present?
      scope.order("#{sort_by_string}")
    else
      scope.order('created_at DESC')
    end
  end

  private

  def filter_by_search(teams)
    search.present? ? teams.where('name ILIKE ?', "%#{search}%") : teams
  end

  def cohort
    if filter[:cohort].blank? || id_from_filter_value(filter[:cohort]).blank?
      return
    end

    course.cohorts.find_by(id: id_from_filter_value(filter[:cohort]))
  end

  def sort_by_string
    case filter[:sort_by]
    when 'Name'
      'teams.name ASC'
    when 'First Created'
      'created_at ASC'
    when 'Last Created'
      'created_at DESC'
    else
      raise "#{filter[:sort_by]} is not a valid sort criterion"
    end
  end

  def resource_school
    course&.school
  end

  def course
    @course ||= Course.find_by(id: course_id)
  end
end
