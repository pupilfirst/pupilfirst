module Users
  class InvitationsController < Devise::InvitationsController
    def edit
      @skip_container = true
      super
    end

    def after_accept_path_for(_resource)
      session[:registration_ongoing] = true
      phone_verification_user_path
    end

    private

    # this is called when creating invitation
    # should return an instance of resource class
    def invite_resource
      ## skip sending emails on invite
      resource_class.invite!(invite_params, current_inviter) do |u|
        u.skip_invitation = true
      end
    end

    # this is called when accepting invitation
    # should return an instance of resource class
    def accept_resource
      resource = resource_class.accept_invitation!(update_resource_params)
      resource.update_attributes(startup: nil) if update_resource_params[:accept_startup] == '0' && resource.valid?
      resource
    end
  end
end
