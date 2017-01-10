class AddUserColumnToBatchApplicant < ActiveRecord::Migration[5.0]
  def change
    add_reference :batch_applicants, :user, foreign_key: true
  end
end
