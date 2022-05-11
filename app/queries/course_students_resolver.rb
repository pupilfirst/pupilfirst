class CourseStudentsResolver < ApplicationQuery
  include AuthorizeSchoolAdmin

  property :course_id
  property :cohort_name
  property :level_name
  property :name
  property :email
  property :user_tags
  property :student_tags
  property :sort_by
  property :sort_direction

  def course_students
    students
  end

  private

  def students
    scope = course.founders
    scope = scope.joins(:user) if name.present? || email.present? ||
      user_tags.present?

    scope = scope.where(level_id: level.id) if level.present?
    scope = scope.where(cohort_id: cohort.id) if cohort.present?
    scope = scope.where('users.name ILIKE ?', "%#{name}%") if name.present?
    scope = scope.where('users.email ILIKE ?', "%#{email}%") if email.present?
    scope = scope.tagged_with(student_tags) if student_tags.present?
    scope =
      scope.where(
        users: {
          id: resource_school.users.tagged_with(user_tags).select(:id)
        }
      ) if user_tags.present?
    scope
  end

  def resource_school
    course&.school
  end

  def cohort
    return if cohort_name.blank?

    course.cohorts.find_by(name: cohort_name)
  end

  def level
    return if level_name.blank?

    course.levels.find_by(number: level_name.split(',').first)
  end

  def course
    @course ||= Course.find(course_id)
  end

  def sort_direction_string
    case sort_direction
    when 'Ascending'
      'ASC'
    when 'Descending'
      'DESC'
    else
      raise "#{sort_direction} is not a valid sort direction"
    end
  end

  def sort_by_string
    case sort_by
    when 'name'
      'users.name'
    when 'created_at'
      'created_at'
    when 'updated_at'
      'updated_at'
    else
      raise "#{sort_by} is not a valid sort criterion"
    end
  end
end
