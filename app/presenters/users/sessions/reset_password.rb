module Users
  module Sessions
    class ResetPassword < ApplicationPresenter
      def initialize(view_context, token, user)
        @token = token
        @user = user
        super(view_context)
      end

      def page_title
        I18n.t("users.sessions.reset_password.page_title", title: current_school.name)
      end

      private

      def props
        {
          authenticity_token: view.form_authenticity_token,
          token: @token,
          name: @user.name,
          email: @user.email,
          school_name: current_school.name
        }
      end
    end
  end
end
