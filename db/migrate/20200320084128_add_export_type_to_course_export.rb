class AddExportTypeToCourseExport < ActiveRecord::Migration[6.0]
  class CourseExport < ActiveRecord::Base
  end

  def up
    add_column :course_exports, :export_type, :string
    CourseExport.reset_column_information
    CourseExport.update_all(export_type: 'Students')
  end

  def down
    remove_column :course_exports, :export_type
  end
end
