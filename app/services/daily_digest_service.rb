# Sends daily digest mails to users who are part of a community, that mentions new questions that have been asked and
# new responses to any of their posts.
class DailyDigestService
  def execute
    updates = questions_from_today
    updates = add_unanswered_questions(updates)

    User.joins(:communities).includes(:communities, :school).each do |user|
      updates_for_user = user.communities.pluck(:id).each_with_object({}) do |community_id, updates_for_user|
        updates_for_user[community_id.to_s] = updates[community_id].dup if updates.include?(community_id)
      end

      next if updates_for_user.blank?

      UserMailer.daily_digest(user, updates_for_user).deliver_later
    end
  end

  private

  # Returns the new questions asked today.
  def questions_from_today
    Question.where('questions.created_at > ?', 1.day.ago)
      .includes(:community, :creator).each_with_object({}) do |question, updates|
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
        type: 'new'
      }
    end
  end

  # Return up to 5 additional, most recent, unanswered questions from communities.
  def add_unanswered_questions(updates)
    Question.where('questions.created_at > ?', 1.week.ago)
      .where('questions.created_at < ?', 1.day.ago)
      .includes(:answers).where(answers: { id: nil })
      .order('questions.created_at DESC').limit(5)
      .includes(:community, :creator).each_with_object(updates) do |question, updates|
      community = question.community

      updates[community.id] ||= {
        community_name: community.name,
        questions: []
      }

      # Increment the number of questions
      updates[community.id][:questions] << {
        id: question.id,
        title: question.title,
        days_ago: (Date.today - question.created_at.to_date).to_i,
        author: question.creator&.name || "a user",
        type: 'unanswered'
      }
    end
  end
end
