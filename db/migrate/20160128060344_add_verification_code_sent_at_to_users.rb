class AddVerificationCodeSentAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :verification_code_sent_at, :datetime
  end
end
