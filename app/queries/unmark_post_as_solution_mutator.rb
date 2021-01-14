class UnmarkPostAsSolutionMutator < ApplicationQuery
  include AuthorizeCommunityUser

  property :id

  def unmark_post_as_solution
    post.update!(solution: false)
    post
  end

  private

  alias authorized? authorized_update?

  def community
    @community ||= post&.community
  end

  def creator
    # Because we're marking a post as a solution, the creator of the topic is considered the 'creator', to allow her to
    # unmark a post as a solution.
    topic&.creator
  end

  def topic
    post&.topic
  end

  def post
    @post ||= Post.find_by(id: id)
  end
end
