class AddPublishAtToCourseModule < ActiveRecord::Migration
  def change
    add_column :course_modules, :publish_at, :datetime
  end
end
