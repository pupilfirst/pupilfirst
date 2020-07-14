module Communities
  # Permanently deletes all data related to a community
  class DeleteService
    def initialize(community)
      @community = community
    end

    def execute
      Community.transaction do
        delete_community_course_connections
        delete_topics

        @community.reload.destroy!
      end
    end

    private

    def delete_community_course_connections
      @community.community_course_connections.delete_all
    end

    def delete_topics
      posts = Post.where(topic_id: @community.topics)
      post_ids = posts.select(:id)

      PostLike.joins(:post).where(posts: {id: post_ids}).delete_all
      TextVersion.where(versionable_type: 'Post', versionable_id: post_ids).delete_all
      posts.delete_all

      Topic.where(community: @community).delete_all
    end
  end
end
