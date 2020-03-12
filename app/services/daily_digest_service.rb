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

    students = User.joins(:communities).distinct.select(:id)
    coaches = User.joins(:faculty).select(:id)
    User.where(id: coaches).or(User.where(id: students))
      .where('preferences @> ?', { daily_digest: true }.to_json)
      .where(email_bounced_at: nil).each do |user|
      updates_for_user = create_updates(updates, user)

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

  def create_updates(updates, user)
    {
      community_updates: add_community_updates(user, updates),
      updates_for_coach: add_updates_for_coach(user)
    }
  end

  def add_community_updates(user, updates)
    return [] if user.communities.blank?

    user.communities.pluck(:id).each_with_object({}) do |community_id, updates_for_user|
      updates_for_user[community_id.to_s] = updates[community_id].dup if updates.include?(community_id)
    end
  end

  def add_updates_for_coach(user)
    coach = user.faculty

    return [] if coach.blank?

    coach.courses.map do |course|
      pending_submissions = course.timeline_events.pending_review
      pending_submissions_in_course = pending_submissions.count

      if pending_submissions_in_course.zero?
        []
      else
        students = Founder.joins(startup: %i[faculty course]).where(faculty: { id: coach }, course: course)
        {
          course_id: course.id,
          course_name: course.name,
          pending_submissions: pending_submissions_in_course,
          pending_submissions_for_coach: pending_submissions.from_founders(students).count
        }
      end
    end.flatten
  end

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
