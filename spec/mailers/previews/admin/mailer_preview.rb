module Admin
  class MailerPreview < ActionMailer::Preview
    def reset_password_instructions
      Devise::Mailer.reset_password_instructions(AdminUser.first, {})
    end
  end
end
