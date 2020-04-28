class UpdatePostMutator < ApplicationQuery
  include AuthorizeCommunityUser

  property :id
  property :body, validates: { length: { minimum: 1, maximum: 10_000 }, presence: true }

  def update_post
    Post.transaction do
      post.text_versions.create!(value: post.body, user: post.creator, edited_at: post.updated_at)
      post.update!(body: body, editor: current_user)
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
end
