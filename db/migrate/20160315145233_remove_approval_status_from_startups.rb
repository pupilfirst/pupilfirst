class RemoveApprovalStatusFromStartups < ActiveRecord::Migration[4.2]
  def change
    remove_column :startups, :approval_status, :string
  end
end
