class RenameCourseToCollegeCourseInFounder < ActiveRecord::Migration[5.2]
  def change
    rename_column :founders, :course, :college_course
  end
end
