class MarkPostAsSolutionMutator < ApplicationQuery
  include AuthorizeCommunityUser

  property :id

  def mark_post_as_solution
    return previous_solution if previous_solution&.id == id

    Post.transaction do
      if previous_solution.present?
        previous_solution.update!(solution: false)
      end

      post.update!(solution: true)
    end

    post
  end

  private

  alias authorized? authorized_update?

  def community
    @community ||= post&.community
  end

  def creator
    # Because we're marking a post as a solution, the creator of the topic is considered the 'creator', to allow her to
    # mark any post as a solution.
    topic&.creator
  end

  def topic
    post&.topic
  end

  def previous_solution
    @previous_solution ||= topic&.solution
  end

  def post
    @post ||= Post.find_by(id: id)
  end
end
