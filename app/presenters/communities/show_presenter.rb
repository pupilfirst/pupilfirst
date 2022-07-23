module Communities
  class ShowPresenter < ApplicationPresenter
    def initialize(view_context, community, target)
      super(view_context)

      @community = community
      @target = target
    end

    def props
      {
        target:
          @target.present? ? @target.attributes.slice('id', 'title') : nil,
        community_id: @community.id,
        topic_categories: topic_categories
      }
    end

    def page_title
      "#{@community.name} #{I18n.t('presenters.communities.show.page_title.community')} | #{current_school.name}"
    end

    private

    def topic_categories
      @community.topic_categories.map do |category|
        { id: category.id, name: category.name }
      end
    end
  end
end
