# Sends daily digest mails to users who are part of a community, that mentions new questions that have been asked and
# new responses to any of their posts.
class DailyDigestService
  def execute
    updates = questions_from_today
    updates = add_unanswered_questions(updates)

    user.joins(:communities).includes(:communities, :school).each do |user|
      updates_for_user = updates.slice(user.communities.pluck(:id))
      UserMailer.daily_digest(user, updates_for_user).deliver_later
    end
  end

  private

  # Returns the new questions asked today.
  def questions_from_today
    Question.where('created_at > ?', 1.day.ago)
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
        days_ago: (question.created_at.to_date - Date.today).to_i,
        author: question.creator&.name || "a user",
        type: :new
      }
    end
  end

  # Return up to 10 additional, most recent, unanswered questions from communities.
  def add_unanswered_questions(updates)
    Question.where('created_at > ?', 1.week.ago)
      .where('created_at < ?', 1.day.ago)
      .includes(:answers).where(answers: { id: nil })
      .order(created_at: :desc).limit(10)
      .includes(:community, creator: :user_profile).each_with_object(updates) do |question, updates|
      community = question.community

      updates[community.id] ||= {
        community_name: community.name,
        questions: []
      }

      # Increment the number of questions
      updates[community.id][:questions] << {
        id: question.id,
        title: question.title,
        days_ago: (question.created_at.to_date - Date.today).to_i,
        author: question.creator&.name || "a user",
        type: :unanswered
      }
    end
  end
end
