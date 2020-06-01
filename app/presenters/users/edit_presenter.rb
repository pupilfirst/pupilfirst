module Users
  class EditPresenter < ApplicationPresenter
    def initialize(view_context)
      super(view_context)
    end

    def page_title
      "User Profile | #{current_school.name}"
    end

    def props
      {
        current_user_id: current_user.id,
        name: current_user.name,
        about: current_user.about || '',
        avatar_url: current_user.avatar.attached? ? current_user.avatar_url(variant: :mid) : nil,
        daily_digest: current_user.preferences['daily_digest']
      }
    end
  end
end
