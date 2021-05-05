def remove_all_communities
  Community.all.each do |community|
    community.community_course_connections.each {|cc| cc.destroy!}
    community.topics.each do |t|
      t.posts.reverse.each do |post|
        post.post_likes.each do |pl|
          pl.destroy!
        end
        post.reload
        post.destroy!
      end
      t.reload
      t.destroy!
    end
    community.reload
    community.destroy!
  end
end
