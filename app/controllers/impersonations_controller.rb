class ImpersonationsController < ApplicationController
  # DELETE /impersonation
  def destroy
    stop_impersonating_user
    redirect_to admin_users_path
  end
end
