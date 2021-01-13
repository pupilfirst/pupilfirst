class AddInvitesSentAtToBatches < ActiveRecord::Migration[4.2]
  def change
    add_column :batches, :invites_sent_at, :datetime
  end
end
