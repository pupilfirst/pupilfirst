class CreateCoachEnrollmentsForTeamCoaches < ActiveRecord::Migration[6.0]
  class Faculty < ActiveRecord::Base
    has_many :faculty_course_enrollments, dependent: :destroy
    has_many :faculty_startup_enrollments, dependent: :destroy
  end

  class Level < ActiveRecord::Base
    belongs_to :course
  end

  class Startup < ActiveRecord::Base
    belongs_to :level
    has_one :course, through: :level
  end

  class FacultyCourseEnrollment < ActiveRecord::Base
    belongs_to :faculty
    belongs_to :course
  end

  class FacultyStartupEnrollment < ActiveRecord::Base
    belongs_to :faculty
    belongs_to :startup
  end

  def up
    FacultyStartupEnrollment.includes(:startup).each do |enrollment|
      next if FacultyCourseEnrollment.where(faculty: enrollment.faculty, course: enrollment.startup.course).present?

      FacultyCourseEnrollment.create!(faculty: enrollment.faculty, course: enrollment.startup.course)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
