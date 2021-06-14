class AddVerifiedAtToApplicants < ActiveRecord::Migration[6.0]
  def change
    add_column :applicants, :email_verified, :boolean, default: false
  end
end
