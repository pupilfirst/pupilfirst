class CreateMilestones < ActiveRecord::Migration[6.1]
  def change
    create_table :milestones do |t|
      t.string :name
      t.integer :sort_index, default: 0

      t.timestamps
    end
  end
end
