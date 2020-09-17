# Sends daily digest mails to users who are part of a community, that mentions new topics that have been discussed and
# new replies to any of their posts.
class DailyDigestService
  def initialize(debug: false)
    @debug = debug
  end

  def execute
    debug_value = {}
    cache_new_and_popular_topics
    cache_older_topics_with_recent_activity

    students = User.joins(:communities).distinct.select(:id)
    coaches = User.joins(:faculty).select(:id)
    User.where(id: coaches).or(User.where(id: students))
      .where('preferences @> ?', { daily_digest: true }.to_json).each do |user|
      next if user.email_bounced?

      updates_for_user = create_updates(community_updates, user)

      next if updates_for_user[:community_updates].blank? && updates_for_user[:updates_for_coach].blank?

      if @debug
        debug_value[user.id] = updates_for_user
      else
        UserMailer.daily_digest(user, updates_for_user).deliver_later
      end
    end

    debug_value
  end

  private

  def cache_new_and_popular_topics
    Topic.live.where('topics.created_at >= ?', recent_time)
      .includes(:community, :creator).sort(views: :DESC).each do |topic|
      cache_topic_details(topic, :new)
    end
  end

  def cache_older_topics_with_recent_activity
    sorted_recently_active_topic_ids = Topic.live.where('topics.created_at < ?', recent_time)
      .joins(:posts).merge(Post.live).where('posts.created_at > ?', recent_time)
      .group('topics.id').order('count_posts_id DESC, views DESC').count('posts.id').keys

    Topic.where(id: sorted_recently_active_topic_ids).each do |topic|
      cache_topic_details(topic, :recently_active)
    end

    sort_cached_recently_active_topics(sorted_recently_active_topic_ids)
  end

  def sort_cached_recently_active_topics(sorted_topic_ids)
    @topic_details_cache[:recently_active].sort_by! do |topic_details|
      sorted_topic_ids.index(topic_details[:id])
    end
  end

  def recent_time
    @recent_time ||= 1.day.ago
  end

  def cache_topic_details(topic, update_type)
    @topic_details_cache[update_type] ||= []

    days_ago = update_type == :new ? 0 : (Date.zone.today - topic.created_at.to_date).to_i

    @topic_details_cache[update_type] << {
      id: topic.id,
      title: topic.title,
      views: topic.views,
      replies: topic.live_replies.count,
      days_ago: days_ago,
      author: topic.creator&.name || 'a user',
      type: type,
      community_id: community.id,
    }
  end

  def create_updates(all_community_updates, user)
    {
      community_updates: add_filtered_community_updates(user, all_community_updates),
      updates_for_coach: add_updates_for_coach(user),
    }
  end

  def add_filtered_community_updates(user, updates)
    communities = communities_for_user(user)

    return [] if communities.blank?

    communities.pluck(:id).each_with_object({}) do |community_id, updates_for_user|
      updates_for_user[community_id.to_s] = updates[community_id].dup if updates.include?(community_id)
    end
  end

  def communities_for_user(user)
    if user.faculty.present?
      Community.joins(:courses).where(courses: { id: user.faculty.courses })
    else
      user.communities
    end
  end

  def add_updates_for_coach(user)
    coach = user.faculty

    return [] if coach.blank?

    coach.courses.map do |course|
      pending_submissions = course.timeline_events.where('timeline_events.created_at > ?', 1.week.ago).pending_review
      pending_submissions_in_course = pending_submissions.count

      if pending_submissions_in_course.zero?
        []
      else
        students = Founder.joins(startup: %i[faculty course]).where(faculty: { id: coach }, courses: { id: course })
        {
          course_id: course.id,
          course_name: course.name,
          pending_submissions: pending_submissions_in_course,
          pending_submissions_for_coach: pending_submissions.from_founders(students).count,
          is_team_coach: students.any?,
        }
      end
    end.flatten
  end

  # Returns the new topics asked today.
  def topics_from_today
    Topic.live.where('topics.created_at > ?', 1.day.ago)
      .includes(:community, :creator).each_with_object({}) do |topic, updates|
      community = topic.community

      add_updates(community, topic, updates, topic.created_at.to_date, 'new')
    end
  end

  # Return up to 5 additional, most recent, topics with no activity from communities.
  def add_topics_with_no_activity(updates)
    Topic.live.where('topics.created_at > ?', 1.week.ago).where('topics.created_at < ?', 1.day.ago)
      .includes(:replies).where(posts: { id: nil })
      .order('topics.created_at DESC').limit(5)
      .includes(:community, :creator).each_with_object(updates) do |topic, updates|
      community = topic.community

      add_updates(community, topic, updates, Time.zone.today, 'no_activity')
    end
  end

  def add_updates(community, topic, updates, from, type)
    updates[community.id] ||= {
      community_name: community.name,
      topics: [],
    }

    # Increment the number of topics
    updates[community.id][:topics] << {
      id: topic.id,
      title: topic.title,
      days_ago: (from - topic.created_at.to_date).to_i,
      author: topic.creator&.name || 'a user',
      type: type,
    }
  end
end
