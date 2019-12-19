class AddReviewedOnlyAndJsonDataToCourseExport < ActiveRecord::Migration[6.0]
  def change
    add_column :course_exports, :reviewed_only, :boolean, default: false
    add_column :course_exports, :json_data, :text
  end
end
