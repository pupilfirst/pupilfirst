class AddFeaturedFlagForCourses < ActiveRecord::Migration[6.0]
  def change
    add_column :courses, :featured, :boolean, default: true
  end
end
