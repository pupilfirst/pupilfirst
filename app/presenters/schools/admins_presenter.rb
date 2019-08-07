module Schools
  class AdminsPresenter < ApplicationPresenter
    def initialize(view_context, school)
      super(view_context)

      @school = school
    end

    private

    def props
      {
        authenticityToken: view.form_authenticity_token,
        admins: admins
      }
    end

    def admins
      @admins ||=
        SchoolAdmin.where(school: @school).includes(user: { avatar_attachment: :blob }).map do |admin|
          {
            id: admin.id,
            name: admin.user.name,
            avatarUrl: admin.user.image_or_avatar_url,
            email: admin.user.email
          }
        end
    end
  end
end
