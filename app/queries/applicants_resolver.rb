class ApplicantsResolver < ApplicationQuery
  include AuthorizeSchoolAdmin

  property :course_id
  property :search
  property :tags
  property :sort_criterion
  property :sort_direction

  def applicants
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
      course.applicants.verified.order(
        "#{sort_criterion_string} #{sort_direction_string}"
      )

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

  def sort_criterion_string
    case sort_criterion
    when 'Name'
      'name'
    when 'CreatedAt'
      'created_at'
    when 'UpdatedAt'
      'updated_at'
    else
      raise "#{sort_criterion} is not a valid sort criterion"
    end
  end
end
