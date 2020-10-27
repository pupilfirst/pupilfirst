after 'development:communities', 'development:topic_categories', 'development:users' do
  puts 'Seeding topics and posts...'

  community = Community.first
  community_users = community.users.first(5)
  topic_categories = community.topic_categories.all + [nil]

  # Let's add a few topics and posts so that the resulting topics paginates the community index.
  3.times do
    community_users.each do |topic_author|
      topic = Topic.create!(
        title: Faker::Lorem.sentence,
        community: community,
        topic_category: topic_categories.sample
      )

      topic.posts.create!(
        post_number: 1,
        body: Faker::Lorem.paragraph(sentence_count: 10, supplemental: false, random_sentences_to_add: 5),
        creator: topic_author
      )

      post_number = 2

      community_users.each_with_index do |reply_author, i|
        next if topic_author == reply_author

        post = topic.posts.create!(
          creator: reply_author,
          post_number: post_number,
          body: Faker::Lorem.paragraph(sentence_count: 10, supplemental: false, random_sentences_to_add: 5)
        )

        post_number += 1

        post.post_likes.create!(user: community_users.sample)

        # Add a reply to each post.
        post.replies.create!(
          topic: topic,
          creator: community_users.sample,
          post_number: post_number,
          body: Faker::Lorem.paragraph(sentence_count: 4, supplemental: false, random_sentences_to_add: 5)
        )

        post_number += 1

        topic.touch(:last_activity_at)
      end
    end
  end
end
