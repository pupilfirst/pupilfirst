class ChangeEmailToBeCitextInApplicants < ActiveRecord::Migration[6.1]
  def change
    change_column :applicants, :email, :citext
  end
end
