class AddDefaultValueToApprovalStatus < ActiveRecord::Migration
  def up
    change_column :startups, :approval_status, :string, default: 'unready'
  end

  def down
    change_column :startups, :approval_status, :string, default: nil
  end
end
