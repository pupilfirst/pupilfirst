class ArchivePostMutator < ApplicationQuery
  include AuthorizeCommunityUser

  property :id

  def archive_post
    Post.transaction do
      post.update!(archived_at: Time.zone.now, archiver: current_user)

      if topic.first_post.id == post.id
        topic.update!(archived: true)
      end
    end
  end

  private

  alias authorized? authorized_archive?

  def community
    topic&.community
  end

  def topic
    post&.topic
  end

  def post
    @post ||= Post.find_by(id: id)
  end

  def creator
    post&.creator
  end
end
