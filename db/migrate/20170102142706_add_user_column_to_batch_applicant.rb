class AddUserColumnToBatchApplicant < ActiveRecord::Migration[5.0]
  def change
    add_column :batch_applicants, :user_id, :integer
  end
end
