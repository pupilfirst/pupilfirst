class TeamsResolver < ApplicationQuery
  include AuthorizeReviewer
  include FilterUtils

  property :course_id
  property :filter_string

  def teams
    scope = course.teams

    scope = scope.active if filter[:include_inactive_teams].blank?
    scope = scope.where(cohort_id: cohort.id) if cohort.present?
    scope = scope.where('teams.name ILIKE ?', "%#{filter[:name]}%") if filter[
      :name
    ].present?

    scope = scope.order("#{sort_by_string}") if filter[:sort_by].present?

    scope
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
end
