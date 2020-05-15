class UpdateCommunityMutator < ApplicationQuery
  include AuthorizeSchoolAdmin

  property :id
  property :name, validates: { length: { minimum: 1, maximum: 50, message: 'InvalidLengthName' } }
  property :target_linkable
  property :course_ids

  validate :course_must_exist_in_current_school

  def course_must_exist_in_current_school
    return if courses.count == course_ids.count

    errors[:base] << 'IncorrectCourseIds'
  end

  def community_must_exist
    return if community.blank?

    errors[:base] << 'IncorrectCommunityId'
  end

  def update_community
    community.update!(
      name: name,
      target_linkable: target_linkable,
      courses: courses,
    )

    community.id
  end

  private

  def resource_school
    community&.school
  end

  def courses
    @courses ||= current_school.courses.where(id: course_ids)
  end

  def community
    @community ||= Community.find_by(id: id)
  end
end
