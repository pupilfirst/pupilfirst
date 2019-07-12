# Sends daily digest mails to users who are part of a community, that mentions new questions that have been asked and
# new responses to any of their posts.
class DailyDigestService
  def execute
    # Prep the digest for each community.
    updates = Question.where('created_at > ?', 1.day.ago)
      .includes(:community, creator: :user_profile).each_with_object({}) do |question, updates|
      community = question.community

      updates[community.id] ||= {
        community_name: community.name,
        questions: []
      }

      # Increment the number of questions
      updates[community.id][:questions] << {
        id: question.id,
        title: question.title,
        author: question.creator.name
      }
    end

    user.joins(:communities).includes(:communities, :school).each do |user|
      updates_for_user = updates.slice(user.communities.pluck(:id))
      UserMailer.daily_digest(user, updates_for_user).deliver_later
    end
  end
end
