class RenameUsersLoginMailSentAt < ActiveRecord::Migration[6.1]
  def change
    rename_column :users, :login_mail_sent_at, :login_token_generated_at
  end
end
