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
    @distribution = { studentDistribution: distribution }
    @filter = prepare_students_filter
  end

  private

  def prepare_students_filter
    {
      id: 'organisation-cohort-students-filter',
      filters: [
        {
          key: 'level',
          label: 'Level',
          filterType: 'MultiSelect',
          values:
            @cohort
              .course
              .levels
              .map { |l| "#{l.number};L#{l.number}: #{l.name}" },
          color: 'green'
        },
        {
          key: 'studentName',
          label: 'Name',
          filterType: 'Search',
          color: 'red'
        },
        {
          key: 'studentEmail',
          label: 'Email',
          filterType: 'Search',
          color: 'yellow'
        }
      ],
      placeholder: 'Filter by level, or search by name or email',
      hint: "...or start typing to search by student's name of email",
      sorter: {
        key: 'sort_by',
        default: 'Last Created',
        options: [
          'Name',
          'First Created',
          'Last Created',
          'First Updated',
          'Last Updated'
        ]
      }
    }
  end

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
