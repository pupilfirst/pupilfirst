class ChangeStartupApprovalStatusToString < ActiveRecord::Migration
  def up
    remove_column :startups, :approval_status
    add_column :startups, :approval_status, :string
  end

  def down
    remove_column :startups, :approval_status
    add_column :startups, :approval_status, :boolean, default: false
  end
end
