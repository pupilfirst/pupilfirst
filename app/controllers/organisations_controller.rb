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
          inactive_cohorts_ids: []
        }
        if cohort.ends_at.nil? || cohort.ends_at.future?
          courses[cohort.course.id][:cohorts] << cohort
        else
          courses[cohort.course.id][:inactive_cohorts_ids] << cohort.id
        end
      end

    courses.values.map do |course|
      cohort_ids = course[:cohorts].map(&:id)

      course[:active_students] = student_count(cohort_ids)
      course[:inactive_students] = student_count(course[:inactive_cohorts_ids])

      course
    end
  end

  def student_count(cohort_ids)
    @organisation
      .users
      .joins(:founders)
      .where(founders: { cohort_id: cohort_ids })
      .distinct
      .count
  end

  def prepare_counts
    scope = @organisation.users

    {
      total_students: scope.joins(:founders).distinct.count,
      active_students:
        scope.joins(founders: :cohort).merge(Cohort.active).distinct.count
    }
  end
end
