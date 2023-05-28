class OrganisationsController < ApplicationController
  before_action :authenticate_user!

  layout 'student'

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
    cohorts = @organisation.cohorts.includes(:course).active.uniq

    courses =
      cohorts.each_with_object({}) do |cohort, courses|
        courses[cohort.course.id] ||= { course: cohort.course, cohorts: [] }
        courses[cohort.course.id][:cohorts] << cohort
      end

    courses.values.map do |course|
      cohort_ids = course[:cohorts].map(&:id)

      course[:total_students] =
        @organisation
          .users
          .joins(:students)
          .where(students: { cohort_id: cohort_ids })
          .distinct
          .count

      course
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
