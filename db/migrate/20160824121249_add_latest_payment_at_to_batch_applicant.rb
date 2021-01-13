class AddLatestPaymentAtToBatchApplicant < ActiveRecord::Migration[4.2]
  def change
    add_column :batch_applicants, :latest_payment_at, :datetime
  end
end
