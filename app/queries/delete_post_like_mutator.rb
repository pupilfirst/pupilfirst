class DeletePostLikeMutator < ApplicationQuery
  property :post_id, validates: { presence: true }

  def delete_post_like
    post_like.destroy! if post_like.present?
  end

  def authorized?
    current_user.present?
  end

  private

  def post_like
    @post_like ||= post.post_likes.where(user: current_user).first
  end

  def post
    @post ||= Post.find_by(id: post_id)
  end
end
