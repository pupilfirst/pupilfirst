class CreateCommunityMutator < ApplicationQuery
  include AuthorizeSchoolAdmin

  property :name, validates: { length: { minimum: 1, maximum: 50 } }
  property :target_linkable
  property :course_ids
  property :topic_categories

  validate :course_must_exist_in_current_school

  def course_must_exist_in_current_school
    return if courses.count == course_ids.count

    errors[:base] << 'invalid courses'
  end

  def create_community
    community = current_school.communities.create!(
      name: name,
      target_linkable: target_linkable,
      courses: courses,
    )
    create_categories(community) if topic_categories.present?

    community
  end

  private

  def resource_school
    current_school
  end

  def create_categories(community)
    topic_categories.each do |category|
      community.topic_categories.create!(name: category)
    end
  end

  def courses
    @courses ||= current_school.courses.where(id: course_ids)
  end
end
