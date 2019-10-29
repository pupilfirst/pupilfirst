module Schools
  class AdminsPresenter < ApplicationPresenter
    def initialize(view_context, school)
      super(view_context)

      @school = school
    end

    private

    def props
      {
        current_school_admin_id: current_school_admin.id,
        admins: admins
      }
    end

    def admins
      @admins ||=
        SchoolAdmin.where(school: @school).includes(user: { avatar_attachment: :blob }).map do |admin|
          details = {
            id: admin.id,
            name: admin.user.name,
            email: admin.user.email
          }

          details[:avatar_url] = admin.user.avatar_url(variant: :thumb) if admin.user.avatar.attached?
          details
        end
    end
  end
end
