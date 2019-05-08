module Communities
  class ShowPresenter < ApplicationPresenter
    def initialize(view_context, community, questions, search, target)
      super(view_context)

      @community = community
      @questions = questions
      @search = search
      @target = target
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
      if question.last_activity_at.blank?
        ""
      else
        time_diff = ((Time.now - question.last_activity_at) / 1.minute).round
        "<span class='hidden md:inline-block'>updated </span><i class='fal fa-history mr-1 md:hidden'></i> #{time_string(time_diff)} <span> ago </span>".html_safe
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

    def new_question?(question)
      question.last_activity_at.blank?
    end

    def page_params(direction)
      page = direction == :next ? @questions.next_page : @questions.prev_page

      kwargs = { page: page }
      kwargs[:search] = @search if @search.present?
      kwargs[:target_id] = @target.id if @target.present?
      kwargs
    end

    private

    def time_string(time)
      if time < 60
        "#{time} minute"
      elsif time < 1440
        "#{(time / 60).round} hour"
      elsif time < 525_600
        "#{(time / 1440).round} Day"
      else
        "#{(time / 525_600).round} Year"
      end
    end
  end
end
