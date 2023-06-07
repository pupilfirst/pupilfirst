class OrganisationsController < ApplicationController
  before_action :authenticate_user!

  layout "student"

  # GET /organisations
  def index
    @organisations = policy_scope(Organisation)

    case @organisations.count
    when 0
      raise_not_found
    when 1
      redirect_to organisation_path(@organisations.first)
    end
  end

  # GET /organisations/:id
  def show
    @organisation = policy_scope(Organisation).find(params[:id])
    @courses_with_cohorts = prepare_courses
    @counts = prepare_counts
  end

  private

  def prepare_courses
    cohorts = @organisation.cohorts.includes(:course).uniq

    courses =
      cohorts.each_with_object({}) do |cohort, courses|
        courses[cohort.course.id] ||= {
          course: cohort.course,
          cohorts: [],
          ended_cohorts_ids: []
        }

        if cohort.ended?
          courses[cohort.course.id][:ended_cohorts_ids] << cohort.id
        else
          courses[cohort.course.id][:cohorts] << cohort
        end
      end

    courses =
      courses.values.map do |course|
        cohort_ids = course[:cohorts].map(&:id)

        course[:active_students] = @organisation
          .users
          .joins(:students)
          .where(students: { cohort_id: cohort_ids })
          .distinct
          .count

        course
      end

    courses.sort_by do |course_data|
      course_data[:cohorts].all?(&:ended?) ? 1 : 0
    end
  end

  def prepare_counts
    scope = @organisation.users

    {
      total_students: scope.joins(:students).distinct.count,
      active_students:
        scope.joins(students: :cohort).merge(Cohort.active).distinct.count
    }
  end
end
