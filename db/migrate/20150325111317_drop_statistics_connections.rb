# While the name of this class seems to imply that the 'statistics' table is being dropped, it is not. Only the
# connections table should be - and it is an error that has been corrected (and did not affect production DB).
class DropStatisticsConnections < ActiveRecord::Migration
  def change
    drop_table :connections
  end
end
