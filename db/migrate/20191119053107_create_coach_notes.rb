class CreateCoachNotes < ActiveRecord::Migration[6.0]
  def change
    create_table :coach_notes do |t|
      t.references :author
      t.references :student
      t.text :note

      t.timestamps
    end
  end
end
