class CreateCommunityMutator < ApplicationQuery
  include AuthorizeSchoolAdmin

  property :name, validates: { length: { minimum: 1, maximum: 50 } }
  property :target_linkable
  property :course_ids

  validate :course_must_exist_in_current_school

  def course_must_exist_in_current_school
    return if courses.count == course_ids.count

    errors[:base] << 'invalid courses'
  end

  def create_community
    current_school.communities.create!(
      name: name,
      target_linkable: target_linkable,
      courses: courses,
    )
  end

  private

  def resource_school
    current_school
  end

  def courses
    @courses ||= current_school.courses.where(id: course_ids)
  end
end
