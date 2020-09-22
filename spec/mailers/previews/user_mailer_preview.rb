class UserMailerPreview < ActionMailer::Preview
  def new_post
    UserMailer.new_post(Post.order('RANDOM()').first, Faculty.last.user)
  end

  def daily_digest
    user = Founder.last.user

    updates = {
      community_new: new_topics,
      community_reactivated: reactivated_topics,
      coach: updates_for_coach
    }

    UserMailer.daily_digest(user, updates)
  end

  def delete_account_token
    school = School.first
    user = school.users.first
    host = school.domains.primary.fqdn
    delete_account_url = Rails.application.routes.url_helpers.delete_account_url(token: 'DELETE_ACCOUNT_TOKEN', host: host, protocol: 'https')
    UserMailer.delete_account_token(user, delete_account_url)
  end

  def confirm_account_deletion
    UserMailer.confirm_account_deletion('test@xyz.com', School.first)
  end

  def account_deletion_notification
    UserMailer.account_deletion_notification(User.last, 'https://test.school.com', 24)
  end

  private

  def new_topics
    community_topics(5, 10, :new)
  end

  def reactivated_topics
    community_topics(5, 1, :reactivated)
  end

  def community_topics(count, starting_id, update_type)
    (0..(count - 1)).map do |index|
      {
        id: starting_id + index,
        title: Faker::Lorem.sentence,
        views: rand(100),
        replies: update_type == :new ? rand(4) : rand(1..5),
        days_ago: update_type == :new ? 0 : rand(1..6),
        author: Faker::Name.name,
        type: update_type,
        community_id: rand(10),
        community_name: Faker::Lorem.words(number: 2).join(' ').titleize
      }
    end
  end

  def updates_for_coach
    (1..3).map do |_id|
      {
        course_id: rand(1..9),
        course_name: Faker::Name.name,
        pending_submissions: rand(1..9),
        pending_submissions_for_coach: rand(0..3)
      }
    end
  end
end
