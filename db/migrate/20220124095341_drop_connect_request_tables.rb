class DropConnectRequestTables < ActiveRecord::Migration[6.1]
  def change
    drop_table :connect_requests
    drop_table :connect_slots
  end
end
