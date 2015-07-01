class Users::RegistrationsController < Devise::RegistrationsController
  protected

  def after_sign_up_path_for(resource)
    referer = session.delete :referer
    referer ? referer : new_session_path(resource)
  end

  def after_inactive_sign_up_path_for(resource)
    after_sign_up_path_for(resource)
  end
end
