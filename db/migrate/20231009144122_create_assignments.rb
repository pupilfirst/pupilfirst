class CreateAssignments < ActiveRecord::Migration[6.1]
  def change
    create_table :assignments do |t|
      t.references :target, null: false, foreign_key: true
      t.string :role
      t.jsonb :checklist
      t.string :completion_instructions
      t.boolean :milestone
      t.integer :milestone_number
      t.boolean :archived

      t.timestamps
    end
  end
end
