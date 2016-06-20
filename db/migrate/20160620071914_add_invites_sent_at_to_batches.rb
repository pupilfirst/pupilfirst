class AddInvitesSentAtToBatches < ActiveRecord::Migration
  def change
    add_column :batches, :invites_sent_at, :datetime
  end
end
