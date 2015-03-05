class Users::PasswordsController < Devise::PasswordsController
  def update
    super do |resource|
      UserMailer.password_changed(resource).deliver
    end
  end
end
