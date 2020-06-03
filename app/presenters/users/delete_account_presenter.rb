module Users
  class DeleteAccountPresenter < ApplicationPresenter
    def initialize(view_context, token)
      @token = token
      super(view_context)
    end

    def page_title
      "Delete Account | #{current_school.name}"
    end

    private

    def props
      {
        token: @token
      }
    end
  end
end
