module Communities
  class ShowPresenter < ApplicationPresenter
    def initialize(view_context, community)
      super(view_context)

      @community = community
    end

    def questions
      @community.questions
    end

    def time(question)
      question.created_at.to_formatted_s(:long)
    end

    def user_name(question)
      question.user.user_profiles.where(school: current_school).first.name
    end

    def comments_count(question)
      question.answers.count
    end

    def comment_claps(question)
      question.answers.joins(:answer_claps).pluck(:count).sum
    end

    def activity(question)
      time_diff = ((Time.now - question.answers.last.updated_at) / 1.minute).round

      if time_diff < 60
        "#{time_diff} M"
      elsif time_diff < 1440
        "#{(time_diff / 60).round} H"
      elsif time_diff < 525_600
        "#{(time_diff / 1440).round} D"
      else
        "#{(time_diff / 525_600).round} Y"
      end
    end
  end
end
