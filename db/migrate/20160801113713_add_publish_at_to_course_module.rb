class AddPublishAtToCourseModule < ActiveRecord::Migration[4.2]
  def change
    add_column :course_modules, :publish_at, :datetime
  end
end
