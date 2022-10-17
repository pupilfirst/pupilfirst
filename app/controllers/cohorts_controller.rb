class CohortsController < ApplicationController
  before_action :authenticate_user!
  layout 'student'

  # GET /organisations/:organisation_id/cohorts/:id
  def show
    @organisation = policy_scope(Organisation).find(params[:organisation_id])
    @cohort = authorize current_school.cohorts.find(params[:id])
    @counts = prepare_counts
  end

  # GET /organisations/:organisation_id/cohorts/:id/students
  def students
    @organisation = policy_scope(Organisation).find(params[:organisation_id])
    @cohort = authorize current_school.cohorts.find(params[:id])
    @distribution = distribution
  end

  private

  def scope
    @scope ||=
      @organisation.founders.not_dropped_out.where(cohort_id: @cohort.id)
  end

  def distribution
    scope
      .joins(:level)
      .group('levels.number')
      .count
      .tap do |dist|
        max_level_number = @cohort.course.levels.where.not(number: 0).count

        (1..max_level_number).each { |level_number| dist[level_number] ||= 0 }
      end
  end

  def prepare_counts
    {
      total: scope.count,
      # completed: scope.where.not(completed_at: nil).count,
      distribution: distribution
    }
  end
end
