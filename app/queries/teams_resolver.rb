class TeamsResolver < ApplicationQuery
  include AuthorizeReviewer

  property :course_id
  property :filter_string

  def teams
    scope = course.teams

    scope = scope.active if filter[:include_inactive_teams].blank?
    scope = scope.where(cohort_id: cohort.id) if cohort.present?
    scope = scope.where('teams.name ILIKE ?', "%#{filter[:name]}%") if filter[
      :name
    ].present?

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

  def filter
    @filter ||=
      URI.decode_www_form(filter_string.presence || '').to_h.symbolize_keys
  end

  def id_from_filter_value(string)
    return unless string

    # Extract the ID from the filter value string, which is in the form of 'id;name_of_the_object
    # e.g. '123;1, Getting Started with Regular Expressions'
    string[/(?<id>.+?);/, 'id']
  end
end
