class CreateStatistics < ActiveRecord::Migration[4.2]
  def change
    create_table :statistics do |t|
      t.string :parameter
      t.text :statistic

      t.timestamps
    end

    add_index :statistics, :parameter
  end
end
