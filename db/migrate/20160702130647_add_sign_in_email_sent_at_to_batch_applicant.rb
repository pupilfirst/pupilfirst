class AddSignInEmailSentAtToBatchApplicant < ActiveRecord::Migration
  def change
    add_column :batch_applicants, :sign_in_email_sent_at, :datetime
  end
end
