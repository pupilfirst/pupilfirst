class AddCohorts < ActiveRecord::Migration[6.1]
  class Startup < ApplicationRecord
    acts_as_taggable

    belongs_to :level
    has_many :founders, dependent: :restrict_with_error
    has_many :faculty_startup_enrollments, dependent: :destroy
    has_many :faculty, through: :faculty_startup_enrollments
    has_one :course, through: :level
  end

  class Tagging < ApplicationRecord
    belongs_to :taggable, polymorphic: true
  end

  class Founder < ApplicationRecord
    acts_as_taggable

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

  class Team < ApplicationRecord
  end

  class FacultyCourseEnrollment < ApplicationRecord
    belongs_to :faculty
    belongs_to :course
  end

  class FacultyStartupEnrollment < ApplicationRecord
    belongs_to :faculty
    belongs_to :startup
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
      t.references :course, foreign_key: true, index: true

      t.timestamps
    end

    create_table :teams do |t|
      t.string :name
      t.references :cohort, foreign_key: true, index: true

      t.timestamps
    end

    add_reference :courses, :default_cohort, foreign_key: { to_table: :cohorts }
    add_column :founders, :dropped_out_at, :datetime
    add_reference :founders, :cohort, foreign_key: true, index: true
    add_reference :founders, :level, foreign_key: true, index: true
    add_reference :founders, :team, foreign_key: true, index: true

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

    courses_count = Course.all.count
    total_startups = Startup.count
    n_updated_startups = 0
    Course.all.each_with_index do |course, index|
      puts "Setting up cohorts #{index + 1}/#{courses_count} :#{course.name}"
      default_cohort =
        Cohort.create!(
          name: 'Purple (Auto-generated)',
          description:
            "Auto generated cohort for active students in #{course.name}",
          ends_at: course.ends_at,
          course_id: course.id
        )

      course
        .startups
        .includes(:founders, :taggings)
        .group_by { |x| x.access_ends_at&.to_date }
        .each do |ends_at, startups|
          cohort =
            if ends_at.nil?
              default_cohort
            else
              Cohort.create!(
                name: "Batch ended on #{ends_at}",
                description:
                  "Cohort created automatically for students whose access_ends_at was #{ends_at}",
                ends_at: ends_at,
                course_id: course.id
              )
            end
          startup_count = startups.count

          startups.each_with_index do |startup, i_s|
            n_updated_startups += 1
            puts "Setting up cohorts #{index + 1}/#{courses_count} :#{course.name} | #{i_s + 1}/#{startup_count} | Total: #{n_updated_startups * 100 / total_startups}%"

            if startup.founders.count > 1
              team = Team.create!(name: startup.name, cohort_id: cohort.id)
            end

            taggings =
              Tagging.where(taggable_id: startup.id, taggable_type: 'Startup')

            startup.founders.each do |student|
              student.update!(
                level_id: startup.level_id,
                cohort_id: cohort.id,
                dropped_out_at: startup.dropped_out_at,
                team_id: team&.id
              )

              taggings.each do |tagging|
                Tagging.create!(
                  tag_id: tagging.tag_id,
                  taggable_id: student.id,
                  taggable_type: 'Founder',
                  context: tagging.context
                )
              end
            end
          end
        end

      course.faculty_course_enrollments.each do |enrollment|
        FacultyCohortEnrollment.create!(
          faculty_id: enrollment.faculty_id,
          cohort_id: default_cohort.id
        )
      end

      course.update!(default_cohort_id: default_cohort.id)
    end

    FacultyStartupEnrollment.all.each do |enrollment|
      enrollment
        .startup
        .founders
        .each do |founder|
          FacultyFounderEnrollment.create!(
            faculty_id: enrollment.faculty_id,
            founder_id: founder.id
          )
        end
    end
  end

  def down
    drop_table :faculty_founder_enrollments
    drop_table :faculty_cohort_enrollments
    remove_column :founders, :team_id
    remove_column :founders, :level_id
    remove_column :founders, :cohort_id
    remove_column :founders, :dropped_out_at
    remove_column :courses, :default_cohort_id
    drop_table :teams
    drop_table :cohorts
  end
end
