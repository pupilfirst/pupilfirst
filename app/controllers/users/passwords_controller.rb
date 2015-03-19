class Users::PasswordsController < Devise::PasswordsController
  def update
    super do |resource|
      UserMailer.password_changed(resource).deliver_later
    end
  end
end
