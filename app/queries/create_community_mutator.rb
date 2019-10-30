class CreateCommunityMutator < ApplicationQuery
  include AuthorizeSchoolAdmin

  attr_accessor :name
  attr_accessor :target_linkable
  attr_accessor :course_ids

  validates :name, length: { minimum: 1, maximum: 50, message: 'InvalidLengthName' }

  validate :course_must_exist_in_current_school

  def course_must_exist_in_current_school
    return if courses.count == course_ids.count

    errors[:base] << 'IncorrectCourseIds'
  end

  def create_community
    Community.create!(
      name: name,
      target_linkable: target_linkable,
      school: current_school,
      courses: courses
    ).id
  end

  private

  def courses
    @courses ||= current_school.courses.where(id: course_ids)
  end
end
