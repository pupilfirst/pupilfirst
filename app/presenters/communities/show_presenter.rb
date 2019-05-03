module Communities
  class ShowPresenter < ApplicationPresenter
    def initialize(view_context, community, questions, search)
      super(view_context)

      @community = community
      @questions = questions
      @search = search
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

    def comment_likes(question)
      question.answers.joins(:answer_likes).count
    end

    def activity(question)
      time = question.answers&.first&.updated_at || question.updated_at
      time_diff = ((Time.now - time) / 1.minute).round

      if time_diff < 60
        "#{time_diff} minute"
      elsif time_diff < 1440
        "#{(time_diff / 60).round} hour"
      elsif time_diff < 525_600
        "#{(time_diff / 1440).round} Day"
      else
        "#{(time_diff / 525_600).round} Year"
      end
    end

    def show_prev_page?
      !@questions.first_page?
    end

    def show_next_page?
      return false if @questions.blank?

      !@questions.last_page?
    end

    def next_page_path
      view.community_path(@community.id, **page_params(:next))
    end

    def prev_page_path
      view.community_path(@community.id, **page_params(:previous))
    end

    def unanswered_questions?(question)
      question.answers.none?
    end

    def page_params(direction)
      page = direction == :next ? @questions.next_page : @questions.prev_page

      kwargs = { page: page }
      kwargs[:search] = @search if @search.present?
      kwargs[:target_id] = @target.id if @target.present?
      kwargs
    end
  end
end
