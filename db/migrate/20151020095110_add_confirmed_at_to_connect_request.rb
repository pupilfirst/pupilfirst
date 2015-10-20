class AddConfirmedAtToConnectRequest < ActiveRecord::Migration
  def change
    add_column :connect_requests, :confirmed_at, :datetime
  end
end
