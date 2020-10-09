class CreateTopicCategoryMutator < ApplicationQuery
  include AuthorizeSchoolAdmin
  property :name, validates: { presence: true, length: { maximum: 50 } }
  property :community_id, validates: { presence: true }

  validate :name_is_unique

  def create_topic_category
    community.topic_categories.create!(name: name)
  end

  private

  def resource_school
    community&.school
  end

  def community
    @community ||= Community.find_by(id: community_id)
  end

  def name_is_unique
    return if community.topic_categories.where(name: name).blank?

    errors[:base] << "Category already exists in community with name: #{name}"
  end
end
