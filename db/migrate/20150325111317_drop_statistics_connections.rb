class DropStatisticsConnections < ActiveRecord::Migration
  def change
    drop_table :statistics
    drop_table :connections
  end
end
