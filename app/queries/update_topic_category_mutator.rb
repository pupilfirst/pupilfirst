class UpdateTopicCategoryMutator < ApplicationQuery
  include AuthorizeSchoolAdmin
  property :id, validates: { presence: true }
  property :name, validates: { presence: true, length: { maximum: 50 } }

  validate :name_is_unique

  def update_topic_category
    topic_category.update!(name: name)
  end

  private

  def resource_school
    topic_category&.community&.school
  end

  def topic_category
    @topic_category ||= TopicCategory.find_by(id: id)
  end

  def name_is_unique
    return if TopicCategory.where(name: name, community_id: topic_category.community_id).blank?

    errors[:base] << "Category already exists in community with name: #{name}"
  end
end
