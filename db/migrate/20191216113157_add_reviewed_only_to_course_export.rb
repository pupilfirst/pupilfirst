class AddReviewedOnlyToCourseExport < ActiveRecord::Migration[6.0]
  def change
    add_column :course_exports, :reviewed_only, :boolean, default: false
  end
end
