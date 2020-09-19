class CreateTopicCategoryMutator < ApplicationQuery
  include AuthorizeSchoolAdmin
  property :name, validates: { presence: true }
  property :community_id, validates: { presence: true }

  def create_topic_category
    category = community.topic_categories.create!(name: name) if community.present?
    category
  end

  private

  def resource_school
    community&.school
  end

  def community
    @community ||= Community.find_by(id: community_id)
  end
end
