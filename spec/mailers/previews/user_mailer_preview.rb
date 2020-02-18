class UserMailerPreview < ActionMailer::Preview
  def new_answer
    UserMailer.new_answer(Answer.order('RANDOM()').first)
  end

  def new_comment
    UserMailer.new_comment(Comment.order('RANDOM()').first)
  end

  def daily_digest
    user = Founder.last.user

    updates = {
      1 => community_digest(2),
      2 => community_digest(1, 3),
      3 => community_digest(3, 4, true)
    }

    UserMailer.daily_digest(user, updates)
  end

  private

  def community_digest(count, starting_id = 1, no_activity = false)
    {
      community_name: Faker::Lorem.words(number: 2).join(' ').titleize,
      questions: (1..count).map do |id|
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
end
