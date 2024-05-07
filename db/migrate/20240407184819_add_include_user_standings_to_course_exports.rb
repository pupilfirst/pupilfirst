class AddIncludeUserStandingsToCourseExports < ActiveRecord::Migration[7.0]
  def change
    add_column :course_exports, :include_user_standings, :boolean, default: false, null: false
  end
end
