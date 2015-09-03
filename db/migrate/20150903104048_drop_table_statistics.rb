class DropTableStatistics < ActiveRecord::Migration
  def up
    drop_table :statistics
  end

  def down
    create_table :statistics do |t|
      t.string :parameter
      t.string :incubation_location
      t.text :statistic

      t.timestamps
    end

    add_index :statistics, :parameter
  end
end
