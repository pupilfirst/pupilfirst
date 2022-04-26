class AddCohorts < ActiveRecord::Migration[6.1]
  class Startup < ApplicationRecord
    belongs_to :level
    has_many :founders, dependent: :restrict_with_error
    has_many :faculty_startup_enrollments, dependent: :destroy
    has_many :faculty, through: :faculty_startup_enrollments
    has_one :course, through: :level
  end

  class Founder < ApplicationRecord
    belongs_to :startup
    has_one :level, through: :startup
    has_one :course, through: :level
  end

  class Level < ApplicationRecord
    has_many :startups, dependent: :restrict_with_error
    belongs_to :course
  end

  class Course < ApplicationRecord
    has_many :levels, dependent: :restrict_with_error
    has_many :startups, through: :levels
    has_many :founders, through: :startups
    has_many :faculty_course_enrollments, dependent: :destroy
    has_many :faculty, through: :faculty_course_enrollments
  end

  class Cohort < ApplicationRecord
  end

  class FacultyCourseEnrollment < ApplicationRecord
    belongs_to :faculty
    belongs_to :course
  end

  class FacultyStartupEnrollment < ApplicationRecord
    belongs_to :faculty
    belongs_to :founder
  end

  class FacultyCohortEnrollment < ApplicationRecord
    belongs_to :faculty
    belongs_to :cohort
  end

  class FacultyFounderEnrollment < ApplicationRecord
    belongs_to :faculty
    belongs_to :founder
  end

  class Faculty < ApplicationRecord
    has_many :faculty_course_enrollments, dependent: :destroy
    has_many :courses, through: :faculty_course_enrollments
    has_many :faculty_startup_enrollments, dependent: :destroy
    has_many :founders, through: :faculty_startup_enrollments
  end

  def up
    create_table :cohorts do |t|
      t.string :name
      t.string :description
      t.datetime :ends_at

      t.timestamps
    end

    add_reference :courses, :default_cohort, foreign_key: { to_table: :cohorts }
    add_column :founders, :access_ends_at, :datetime
    add_column :founders, :dropped_out_at, :datetime
    add_reference :founders, :cohort, foreign_key: true, index: true
    add_reference :founders, :level, foreign_key: true, index: true

    create_table :faculty_cohort_enrollments do |t|
      t.references :faculty, foreign_key: true
      t.references :cohort, foreign_key: true, index: false

      t.timestamps
    end

    add_index :faculty_cohort_enrollments,
              %i[cohort_id faculty_id],
              unique: true

    create_table :faculty_founder_enrollments do |t|
      t.references :faculty, foreign_key: true
      t.references :founder, foreign_key: true, index: false

      t.timestamps
    end

    add_index :faculty_founder_enrollments,
              %i[founder_id faculty_id],
              unique: true

    Founder.reset_column_information
    Course.reset_column_information

    Course.all.each do |course|
      cohort =
        Cohort.create!(
          name: 'Default cohort',
          description: "Default cohort for #{course.name}",
          ends_at: course.ends_at
        )

      course.founders.each do |student|
        student.update!(
          level_id: student.startup.level_id,
          cohort_id: cohort.id,
          access_ends_at: student.startup.access_ends_at,
          dropped_out_at: student.startup.dropped_out_at
        )
      end

      course.faculty_course_enrollments.each do |enrollment|
        FacultyCohortEnrollment.create!(
          faculty_id: enrollment.faculty_id,
          cohort_id: cohort.id
        )
      end

      course.update!(default_cohort_id: cohort.id)
    end

    FacultyStartupEnrollment.all.each do |enrollment|
      enrollment
        .startup
        .founders
        .each do |founder|
          FacultyFounderEnrollment.create!(
            faculty_id: enrollment.faculty_id,
            founder_id: enrollment.founder.id
          )
        end
    end
  end

  def down
    # raise ActiveRecord::IrreversibleMigration
  end
end
