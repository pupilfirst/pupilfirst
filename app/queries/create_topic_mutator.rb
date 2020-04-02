class CreateTopicMutator < ApplicationQuery
  include AuthorizeCommunityUser

  property :title, validates: { length: { minimum: 1, maximum: 250 }, allow_nil: false }
  property :body, validates: { length: { minimum: 1, maximum: 15_000 }, allow_nil: false }
  property :community_id, validates: { presence: true }
  property :target_id

  def create_topic
    Topic.transaction do
      topic = Topic.create!(
        title: title,
        community: community,
        target_id: target&.id
      )

      topic.posts.create!(
        post_number: 1,
        body: body,
        creator: current_user
      )

      topic
    end
  end

  private

  alias authorized? authorized_create?

  def community
    @community ||= Community.find_by(id: community_id)
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
      current_user.founders.joins(:course).where(courses: { id: some_target.course.id }).exists?
  end
end
