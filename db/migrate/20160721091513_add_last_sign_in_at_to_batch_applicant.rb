class AddLastSignInAtToBatchApplicant < ActiveRecord::Migration[4.2]
  def change
    add_column :batch_applicants, :last_sign_in_at, :datetime
  end
end
