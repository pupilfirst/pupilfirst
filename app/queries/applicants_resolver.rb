class ApplicantsResolver < ApplicationQuery
  include AuthorizeSchoolAdmin

  property :course_id
  property :search
  property :tags
  property :sort_by
  property :sort_direction

  def course_teams
    if search.present?
      applicants_by_tag
        .where('name ILIKE ?', "%#{search}%")
        .or(applicants_by_tag.where('email ILIKE ?', "%#{search}%"))
    else
      applicants_by_tag
    end
  end

  private

  def resource_school
    course&.school
  end

  def course
    @course ||= Course.find(course_id)
  end

  def applicants_by_tag
    course_applicants =
      course.applicants.order("#{sort_by_string} #{sort_direction_string}")

    if tags.present?
      course_applicants.joins(taggings: :tag).where(tags: { name: tags })
    else
      course_applicants.includes(taggings: :tag)
    end
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
      'name'
    when 'created_at'
      'created_at'
    when 'updated_at'
      'updated_at'
    else
      raise "#{sort_by} is not a valid sort criterion"
    end
  end
end
