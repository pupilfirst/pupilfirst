module Founders
  class MailerPreview < ActionMailer::Preview
    # helper :application # gives access to all helpers defined within `application_helper`.
    # include Devise::Controllers::UrlHelpers # Optional. eg. `confirmation_url`.
    # hit http://localhost:3000/rails/mailers/founders/mailer/confirmation_instructions
    def confirmation_instructions
      Devise::Mailer.confirmation_instructions(Founder.first, {})
    end

    # hit http://localhost:3000/rails/mailers/founders/mailer/reset_password_instructions
    def reset_password_instructions
      Devise::Mailer.reset_password_instructions(Founder.first, {})
    end

    # hit http://localhost:3000/rails/mailers/founders/mailer/unlock_instructions
    def unlock_instructions
      Devise::Mailer.unlock_instructions(Founder.first, {})
    end

    def invitation_instructions
      Devise::Mailer.reset_password_instructions(Founder.first, {})
    end
  end
end
