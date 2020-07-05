class UserMailerPreview < ActionMailer::Preview
  def new_post
    UserMailer.new_post(Post.order('RANDOM()').first, Faculty.last.user)
  end

  def daily_digest
    user = Founder.last.user

    community_updates = {
      1 => community_digest(2),
      2 => community_digest(1, 3),
      3 => community_digest(3, 4, true)
    }

    updates = {
      community_updates: community_updates,
      updates_for_coach: updates_for_coach
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

  def community_digest(count, starting_id = 1, no_activity = false)
    {
      community_name: Faker::Lorem.words(number: 2).join(' ').titleize,
      topics: (1..count).map do |id|
        {
          id: starting_id + id - 1,
          title: Faker::Lorem.sentence,
          author: Faker::Name.name,
          days_ago: no_activity ? rand(1..6) : 0,
          type: no_activity ? 'no_activity' : 'new'
        }
      end
    }
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
