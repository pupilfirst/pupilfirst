class Users::MailerPreview < ActionMailer::Preview
  # helper :application # gives access to all helpers defined within `application_helper`.
  # include Devise::Controllers::UrlHelpers # Optional. eg. `confirmation_url`.
  add_template_helper(Devise::Controllers::UrlHelpers)

  # hit http://localhost:3000/rails/mailers/users/mailer/confirmation_instructions
  def confirmation_instructions
    Devise::Mailer.confirmation_instructions(User.first, {})
  end

  # hit http://localhost:3000/rails/mailers/users/mailer/reset_password_instructions
  def reset_password_instructions
    Devise::Mailer.reset_password_instructions(User.first, {})
  end

  # hit http://localhost:3000/rails/mailers/users/mailer/unlock_instructions
  def unlock_instructions
    Devise::Mailer.unlock_instructions(User.first, {})
  end
end