class DeletePostLikeMutator < ApplicationQuery
  property :id, validates: { presence: true }

  def delete_post_like
    post_like.destroy!
  end

  def authorized?
    # User must be signed in, and must be the owner of the 'like'.
    current_user.present? && post_like&.user == current_user
  end

  private

  def post_like
    @post_like ||= PostLike.find_by(id: id)
  end
end
