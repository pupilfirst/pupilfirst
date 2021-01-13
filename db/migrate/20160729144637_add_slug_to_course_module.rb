class AddSlugToCourseModule < ActiveRecord::Migration[4.2]
  def change
    add_column :course_modules, :slug, :string
    add_index :course_modules, :slug
  end
end
