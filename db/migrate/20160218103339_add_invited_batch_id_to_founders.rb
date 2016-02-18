class AddInvitedBatchIdToFounders < ActiveRecord::Migration
  def change
    add_column :founders, :invited_batch_id, :integer
    add_index :founders, :invited_batch_id
  end
end
