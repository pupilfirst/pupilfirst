class AddSeoSlugToCourses < ActiveRecord::Migration[6.1]
  def change
    add_column :courses, :seo_slug, :string

    Course.all.each{ |course| course.save! }
  end
end
