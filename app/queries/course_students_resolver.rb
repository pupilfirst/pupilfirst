class CourseStudentsResolver < ApplicationQuery
  include AuthorizeSchoolAdmin

  property :course_id
  property :cohort_id
  property :level_id
  property :search
  property :tags
  property :sort_by
  property :sort_direction

  def course_students
    if search.present?
      students_by_level_and_tag
        .where('users.name ILIKE ?', "%#{search}%")
        .or(
          students_by_level_and_tag.where('users.email ILIKE ?', "%#{search}%")
        )
    else
      students_by_level_cohort_and_tag
    end
  end

  private

  def resource_school
    course&.school
  end

  def course
    @course ||= Course.find(course_id)
  end

  def students_by_tag
    students = course.founders.joins(:user)

    return students if tags.blank?

    user_tags =
      tags.intersection(
        course
          .users
          .joins(taggings: :tag)
          .distinct('tags.name')
          .pluck('tags.name')
      )

    student_tags =
      tags.intersection(
        course
          .founders
          .joins(taggings: :tag)
          .distinct('tags.name')
          .pluck('tags.name')
      )

    intersect_students = user_tags.present? && student_tags.present?

    student_with_user_tags =
      students
        .where(
          users: {
            id: resource_school.users.tagged_with(user_tags).select(:id)
          }
        )
        .pluck(:id)

    students_with_tags = students.tagged_with(team_tags).pluck(:id)

    if intersect_students
      students.where(
        id: students_with_user_tags.intersection(students_with_tags)
      )
    else
      students.where(id: students_with_user_tags + students_with_tags)
    end
  end

  def students_by_level_cohort_and_tag
    scope =
      if level_id.present?
        students_by_tag.where(level_id: level_id)
      else
        students_by_tag
      end

    (cohort_id.present? ? scope.where(cohort_id: cohort_id) : scope).order(
      "#{sort_by_string} #{sort_direction_string}"
    )
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
