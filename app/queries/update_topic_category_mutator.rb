class UpdateTopicCategoryMutator < ApplicationQuery
  include AuthorizeSchoolAdmin
  property :id, validates: { presence: true }
  property :name, validates: { presence: true }

  def update_topic_category
    topic_category.update!(name: name) if topic_category.present?
  end

  private

  def resource_school
    topic_category&.community&.school
  end

  def topic_category
    @topic_category ||= TopicCategory.find_by(id: id)
  end
end
