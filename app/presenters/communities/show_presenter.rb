module Communities
  class ShowPresenter < ApplicationPresenter
    def initialize(view_context, community)
      super(view_context)

      @community = community
    end

    def questions
      @community.questions
    end
  end
end
