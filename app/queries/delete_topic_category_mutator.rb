class DeleteTopicCategoryMutator < ApplicationQuery
  include AuthorizeSchoolAdmin
  property :id, validates: { presence: true }

  def delete_topic_category
    topic_category.destroy! if topic_category.present?
  end

  private

  def resource_school
    topic_category&.community&.school
  end

  def topic_category
    @topic_category ||= TopicCategory.find_by(id: id)
  end
end
