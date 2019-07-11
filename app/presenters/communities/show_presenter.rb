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

    def page_title
      "#{@community.name} Community | #{current_school.name}"
    end

    def creator_name(question)
      question.creator.name
    end

    def comments_count(question)
      question.answers.count
    end

    def comment_likes(question)
      question.answers.joins(:answer_likes).count
    end

    def activity(question)
      view.time_ago_in_words(question.last_activity_at)
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
  end
end
