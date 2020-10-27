class UpdatePostMutator < ApplicationQuery
  include AuthorizeCommunityUser

  property :id
  property :body, validates: { length: { minimum: 1, maximum: 10_000 }, presence: true }
  property :edit_reason, validates: { length: { maximum: 500, allow_blank: true } }

  def update_post
    Post.transaction do
      post.text_versions.create!(value: post.body, user: post.creator, edited_at: post.updated_at, reason: post.edit_reason)
      post.update!(body: body, editor: current_user, edit_reason: sanitized_edit_reason)
      post
    end
  end

  private

  alias authorized? authorized_update?

  def community
    @community ||= post&.community
  end

  def creator
    post&.creator
  end

  def post
    @post ||= Post.find_by(id: id)
  end

  def sanitized_edit_reason
    edit_reason&.strip.presence
  end

end
