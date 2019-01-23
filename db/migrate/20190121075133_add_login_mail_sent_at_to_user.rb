class AddLoginMailSentAtToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :login_mail_sent_at, :datetime
  end
end
