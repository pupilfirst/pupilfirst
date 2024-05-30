class CreatePostLikeMutator < ApplicationQuery
  include AuthorizeCommunityUser

  property :post_id, validates: { presence: true }

  def create_post_like
    PostLike.create_or_find_by!(user: current_user, post: post)
  end

  private

  alias authorized? authorized_create?

  def community
    @community ||= post&.community
  end

  def post
    @post ||= Post.find_by(id: post_id)
  end
end
