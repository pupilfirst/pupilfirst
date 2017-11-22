class CreatePerformanceCriteria < ActiveRecord::Migration[5.1]
  def change
    create_table :performance_criteria do |t|
      t.string :description

      t.timestamps
    end
  end
end
