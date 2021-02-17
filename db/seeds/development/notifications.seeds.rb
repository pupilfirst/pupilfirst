after 'development:communities', 'development:posts', 'development:users' do
  puts 'Seeding notifications'
  community_users = Community.first.users.first(5)
  community_topics = Community.first.topics

  community_topics.each do |topic|
    community_users.each do |recipient|
      Notification.create!(
        actor_id: topic.creator.id,
        notifiable: topic,
        event: Notification.events[:topic_created],
        recipient: recipient,
        message:
          I18n.t(
            'jobs.notifications.topic_created_job.topic_created',
            user_name: topic.creator.name,
            community_name: topic.community.name,
          )
      )
    end
  end
end
