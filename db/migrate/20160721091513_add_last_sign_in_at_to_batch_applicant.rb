class AddLastSignInAtToBatchApplicant < ActiveRecord::Migration
  def change
    add_column :batch_applicants, :last_sign_in_at, :datetime
  end
end
