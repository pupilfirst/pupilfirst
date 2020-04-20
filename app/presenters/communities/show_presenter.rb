module Communities
  class ShowPresenter < ApplicationPresenter
    def initialize(view_context, community, topics, search, target)
      super(view_context)

      @community = community
      @topics = topics
      @search = search
      @target = target
    end

    def time(topic)
      topic.created_at.to_formatted_s(:long)
    end

    def page_title
      "#{@community.name} Community | #{current_school.name}"
    end

    def creator_name(topic)
      topic.first_post.creator.name
    end

    def activity(topic)
      view.time_ago_in_words(topic.last_activity_at)
    end

    def show_prev_page?
      !@topics.first_page?
    end

    def show_next_page?
      return false if @topics.blank?

      !@topics.last_page?
    end

    def next_page_path
      view.community_path(@community.id, **page_params(:next))
    end

    def prev_page_path
      view.community_path(@community.id, **page_params(:previous))
    end

    def new_topic?(topic)
      topic.last_activity_at.blank?
    end

    def page_params(direction)
      page = direction == :next ? @topics.next_page : @topics.prev_page

      kwargs = { page: page }
      kwargs[:search] = @search if @search.present?
      kwargs[:target_id] = @target.id if @target.present?
      kwargs
    end
  end
end
