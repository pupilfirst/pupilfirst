class AddLatestPaymentAtToBatchApplicant < ActiveRecord::Migration
  def change
    add_column :batch_applicants, :latest_payment_at, :datetime
  end
end
