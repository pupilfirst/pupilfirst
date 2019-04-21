module Communities
  class ShowPresenter < ApplicationPresenter
    def initialize(view_context, community, questions)
      super(view_context)

      @community = community
      @questions = questions
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
      time = question.answers&.first&.updated_at || question.updated_at
      time_diff = ((Time.now - time) / 1.minute).round

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

    def show_prev_page?
      !@questions.first_page?
    end

    def show_next_page?
      !@questions.last_page?
    end

    def next_page_path
      view.community_path(@community.id, page: @questions.next_page)
    end

    def prev_page_path
      view.community_path(@community.id, page: @questions.prev_page)
    end

    def unanswered_questions?(question)
      question.answers.none?
    end
  end
end
