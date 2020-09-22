module Communities
  class ShowPresenter < ApplicationPresenter
    def initialize(view_context, community, target)
      super(view_context)

      @community = community
      @target = target
    end

    def time(topic)
      topic.created_at.to_formatted_s(:long)
    end

    def props
      {
        target: @target.present? ? @target.attributes.slice('id', 'title') : nil,
        community_id: @community.id,
        topic_categories: topic_categories
      }
    end

    def topic_categories
      @community.topic_categories.map { |category| { id: category.id, name: category.name } }
    end

    def page_title
      "#{@community.name} Community | #{current_school.name}"
    end

    def new_topic?(topic)
      topic.last_activity_at.blank?
    end
  end
end
