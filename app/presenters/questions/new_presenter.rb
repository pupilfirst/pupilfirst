module Questions
  class NewPresenter < ApplicationPresenter
    def initialize(view_context, community, target)
      super(view_context)
      @community = community
      @target = target
    end

    def json_props
      {
        authenticityToken: view.form_authenticity_token,
        communityId: @community.id.to_s,
        communityPath: view.community_path(@community),
        target: @target.present? ? { id: @target.id.to_s, title: @target.title } : nil
      }.to_json
    end

    def page_title
      "New Question | #{@community.name} Community"
    end
  end
end
