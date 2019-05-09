module Questions
  class NewPresenter < ApplicationPresenter
    def initialize(view_context, community)
      super(view_context)
      @community = community
    end

    def json_props
      {
        authenticityToken: view.form_authenticity_token,
        communityId: @community.id.to_s,
        communityPath: view.community_path(@community)
      }.to_json
    end
  end
end
