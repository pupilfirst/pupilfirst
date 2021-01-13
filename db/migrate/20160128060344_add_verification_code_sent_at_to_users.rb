class AddVerificationCodeSentAtToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :verification_code_sent_at, :datetime
  end
end
