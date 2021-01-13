class AddDefaultValueToApprovalStatus < ActiveRecord::Migration[4.2]
  def up
    change_column :startups, :approval_status, :string, default: 'unready'
  end

  def down
    change_column :startups, :approval_status, :string, default: nil
  end
end
