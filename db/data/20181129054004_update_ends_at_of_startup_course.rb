class UpdateEndsAtOfStartupCourse < ActiveRecord::Migration[5.2]
  def up
    course = Course.find_by(name: 'Startup')
    course.update!(ends_at: DateTime.new(2018,01,01))
  end

  def down
    course = Course.find_by(name: 'Startup')
    course.update!(ends_at: nil)
  end
end
