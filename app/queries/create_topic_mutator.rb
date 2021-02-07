class CreateTopicMutator < ApplicationQuery
  include AuthorizeCommunityUser

  property :title, validates: { length: { minimum: 1, maximum: 250 }, allow_nil: false }
  property :body, validates: { length: { minimum: 1, maximum: 15_000 }, allow_nil: false }
  property :community_id, validates: { presence: true }
  property :target_id
  property :topic_category_id

  def create_topic
    Topic.transaction do
      topic = Topic.create!(
        title: title,
        community: community,
        target_id: target&.id,
        topic_category: topic_category
      )

      topic.posts.create!(
        post_number: 1,
        body: body,
        creator: current_user
      )

      create_subscribers(topic)

      Notifications::TopicCreatedJob.perform_later(current_user.id, topic.id)

      topic
    end
  end

  private

  alias authorized? authorized_create?

  def community
    @community ||= Community.find_by(id: community_id)
  end

  def topic_category
    return if topic_category_id.blank?

    community.topic_categories.find_by(id: topic_category_id)
  end

  def create_subscribers(topic)
    users = User.joins([faculty: :startups]).where(startups: { id: current_user.startups }).distinct + [current_user]

    users.each do |user|
      TopicSubscription.create!(user: user, topic: topic)
    end
  end

  def target
    @target ||= begin
      t = Target.find_by(id: target_id)

      if t.present? && t.course.school == current_school && target_accessible?(t)
        t
      end
    end
  end

  def target_accessible?(some_target)
    current_school_admin.present? ||
      current_user.faculty.present? ||
      current_user.founders.joins(:course).exists?(courses: { id: some_target.course.id })
  end
end
