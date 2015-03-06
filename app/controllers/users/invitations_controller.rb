class Users::InvitationsController < Devise::InvitationsController

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
    resource.update_attributes(startup: nil) if update_resource_params[:accept_startup] == "0" and resource.valid?
    resource
  end
end
