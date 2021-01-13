class AddSignInEmailSentAtToBatchApplicant < ActiveRecord::Migration[4.2]
  def change
    add_column :batch_applicants, :sign_in_email_sent_at, :datetime
  end
end
