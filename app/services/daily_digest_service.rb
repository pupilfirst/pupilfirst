# Sends daily digest mails to users who are part of a community, that mentions new questions that have been asked and
# new responses to any of their posts.
class DailyDigestService
  def initialize(debug: false)
    @debug = debug
  end

  def execute
    debug_value = {}
    updates = questions_from_today
    updates = add_questions_with_no_activity(updates)

    User.joins(:communities).includes(:communities, :school).joins(:founders)
      .where('preferences @> ?', { daily_digest: true }.to_json)
      .where(founders: { exited_on: nil })
      .where(email_bounced_at: nil).each do |user|
      updates_for_user = user.communities.pluck(:id).each_with_object({}) do |community_id, updates_for_user|
        updates_for_user[community_id.to_s] = updates[community_id].dup if updates.include?(community_id)
      end

      next if updates_for_user.blank?

      if @debug
        debug_value[user.id] = updates_for_user
      else
        UserMailer.daily_digest(user, updates_for_user).deliver_later
      end
    end

    debug_value
  end

  private

  # Returns the new questions asked today.
  def questions_from_today
    Question.live.where('questions.created_at > ?', 1.day.ago)
      .includes(:community, :creator).each_with_object({}) do |question, updates|
      community = question.community

      add_updates(community, question, updates, question.created_at.to_date, 'new')
    end
  end

  # Return up to 5 additional, most recent, questions with no activity from communities.
  def add_questions_with_no_activity(updates)
    Question.live.where('questions.created_at > ?', 1.week.ago)
      .where('questions.created_at < ?', 1.day.ago)
      .includes(:answers, :comments).where(answers: { id: nil }, comments: { id: nil })
      .order('questions.created_at DESC').limit(5)
      .includes(:community, :creator).each_with_object(updates) do |question, updates|
      community = question.community

      add_updates(community, question, updates, Date.today, 'no_activity')
    end
  end

  def add_updates(community, question, updates, from, type)
    updates[community.id] ||= {
      community_name: community.name,
      questions: []
    }

    # Increment the number of questions
    updates[community.id][:questions] << {
      id: question.id,
      title: question.title,
      days_ago: (from - question.created_at.to_date).to_i,
      author: question.creator&.name || "a user",
      type: type
    }
  end
end
