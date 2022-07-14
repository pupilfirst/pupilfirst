class CourseStudentsResolver < ApplicationQuery
  include AuthorizeReviewer

  property :course_id
  property :filter_string

  def course_students
    students
  end

  private

  def students
    scope = course.founders
    scope = scope.joins(:user) if filter[:name].present? ||
      filter[:email].present? || filter[:user_tags].present?

    scope = scope.where(level_id: level.id) if level.present?
    scope = scope.where(cohort_id: cohort.id) if cohort.present?
    scope = scope.where('users.name ILIKE ?', "%#{filter[:name]}%") if filter[
      :name
    ].present?
    scope = scope.where('users.email ILIKE ?', "%#{filter[:email]}%") if filter[
      :email
    ].present?
    scope = scope.tagged_with(filter[:student_tags].split(',')) if filter[
      :student_tags
    ].present?

    scope =
      scope.where(
        users: {
          id:
            resource_school
              .users
              .tagged_with(filter[:user_tags].split(','))
              .select(:id)
        }
      ) if filter[:user_tags].present?
    scope
  end

  def resource_school
    course&.school
  end

  def cohort
    if filter[:cohort].blank? || id_from_filter_value(filter[:cohort]).blank?
      return
    end

    course.cohorts.find_by(id: id_from_filter_value(filter[:cohort]))
  end

  def level
    if filter[:level].blank? || id_from_filter_value(filter[:level]).blank?
      return
    end

    course.levels.find_by(id: id_from_filter_value(filter[:level]))
  end

  def course
    @course ||= Course.find(course_id)
  end

  def sort_direction_string
    case filter[:sort_direction]
    when 'Ascending'
      'ASC'
    when 'Descending'
      'DESC'
    else
      raise "#{filter[:sort_direction]} is not a valid sort direction"
    end
  end

  def sort_by_string
    case filter[:sort_by]
    when 'name'
      'users.name'
    when 'created_at'
      'created_at'
    when 'updated_at'
      'updated_at'
    else
      raise "#{filter[:sort_by]} is not a valid sort criterion"
    end
  end

  def filter
    @filter ||=
      URI.decode_www_form(filter_string.presence || '').to_h.symbolize_keys
  end

  # Todo: Should get this reviewed
  def id_from_filter_value(string)
    return unless string

    # Extract the ID from the filter value string, which is in the form of 'id;name_of_the_object
    # e.g. '123;1, Getting Started with Regular Expressions'
    string[/(?<id>(.+?);)/, 'id']&.gsub(';', '')
  end
end
