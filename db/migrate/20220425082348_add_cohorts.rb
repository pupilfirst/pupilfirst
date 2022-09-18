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
          name: 'Default cohort',
          description: "Default cohort for #{course.name}",
          ends_at: course.ends_at,
          course_id: course.id
        )

      course
        .startups
        .includes(:founders)
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

            startup.founders.each do |student|
              student.update!(
                level_id: student.startup.level_id,
                cohort_id: cohort.id,
                dropped_out_at: student.startup.dropped_out_at,
                team_id: team&.id
              )
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

    remove_column :founders, :startup_id
    remove_column :founders, :resume_file_id

    drop_table :faculty_course_enrollments
    drop_table :faculty_startup_enrollments
    drop_table :startups
    remove_column :courses, :ends_at

    # Clean up slack
    remove_column :faculty, :slack_username
    remove_column :faculty, :slack_user_id

    remove_column :founders, :slack_username
    remove_column :founders, :slack_user_id

    remove_column :targets, :slack_reminders_sent_at

    drop_table :public_slack_messages
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
