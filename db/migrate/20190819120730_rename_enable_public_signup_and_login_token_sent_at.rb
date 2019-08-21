class RenameEnablePublicSignupAndLoginTokenSentAt < ActiveRecord::Migration[5.2]
  def change
    rename_column :courses, :enable_public_signup, :public_signup
    rename_column :applicants, :login_token_sent_at, :login_mail_sent_at
  end
end
