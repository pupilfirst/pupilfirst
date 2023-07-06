class UpdateCourseProgressionLimitfromCurrentBehavior < ActiveRecord::Migration[
  6.1
]
  def up
    Course.all.each do |course|
      if course.progression_behavior == Course::PROGRESSION_BEHAVIOR_UNLIMITED
        course.update!(progression_limit: 0)
      elsif course.progression_behavior == Course::PROGRESSION_BEHAVIOR_LIMITED
        progression_limit = course.progression_limit + 1
        course.update!(progression_limit: [progression_limit, 3].min)
      elsif course.progression_behavior == Course::PROGRESSION_BEHAVIOR_STRICT
        course.update!(progression_limit: 1)
      end
    end

    change_column_null :courses, :progression_behavior, true
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
