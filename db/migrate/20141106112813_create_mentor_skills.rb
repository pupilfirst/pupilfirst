class CreateMentorSkills < ActiveRecord::Migration
  def change
    create_table :mentor_skills do |t|
      t.references :mentor, index: true
      t.references :skill, index: true
      t.string :expertise

      t.timestamps
    end
  end
end
