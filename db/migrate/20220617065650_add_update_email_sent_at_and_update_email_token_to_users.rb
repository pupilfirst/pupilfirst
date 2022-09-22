class AddUpdateEmailSentAtAndUpdateEmailTokenToUsers < ActiveRecord::Migration[
  6.1
]
  def change
    add_column :users, :update_email_token, :string
    add_column :users, :update_email_token_sent_at, :datetime
    add_column :users, :new_email, :string
  end
end
