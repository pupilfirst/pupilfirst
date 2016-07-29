class CreateChapterSections < ActiveRecord::Migration
  def change
    create_table :chapter_sections do |t|
      t.integer :course_chapter_id
      t.string :name
      t.integer :section_number

      t.timestamps null: false
    end
    add_index :chapter_sections, :course_chapter_id
  end
end
