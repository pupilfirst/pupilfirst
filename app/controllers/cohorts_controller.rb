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
    counts = scope.joins(:level).group('levels.number').count

    @cohort
      .course
      .levels
      .where.not(number: 0)
      .map do |level|
        {
          id: level.id.to_s,
          number: level.number,
          filterName: 'level',
          studentsInLevel: counts[level.number] || 0,
          unlocked: level.unlocked?
        }
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
