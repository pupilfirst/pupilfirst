module Cohorts
  class StudentsPresenter < ApplicationPresenter
    def initialize(view_context, organisation, cohort)
      @organisation = organisation
      @cohort = cohort
      super(view_context)
    end

    def distribution
      @distribution ||=
        begin
          counts = scope.joins(:level).group('levels.number').count

          dist =
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

          { studentDistribution: dist }
        end
    end

    def filter
      @filter ||=
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
            { key: 'name', label: 'Name', filterType: 'Search', color: 'red' },
            {
              key: 'email',
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

    def counts
      @counts = {
        total: scope.count
        # TODO: Uncomment and use the following figure when related branch has been merged.
        # completed: scope.where.not(completed_at: nil).count
      }
    end

    private

    def scope
      @scope ||=
        @organisation.founders.not_dropped_out.where(cohort_id: @cohort.id)
    end
  end
end
