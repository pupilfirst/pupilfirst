class RemoveApprovalStatusFromStartups < ActiveRecord::Migration
  def change
    remove_column :startups, :approval_status, :string
  end
end
