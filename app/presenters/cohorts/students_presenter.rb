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

    def students
      filter_1 = filter_students_by_level(scope)
      filter_2 = filter_students_by_name(filter_1)
      filter_3 = filter_students_by_email(filter_2)
      sorted = sort_students(filter_3)
      paginate_students(sorted)
    end

    def filter_students_by_level(scope)
      if params[:level].present?
        scope.joins(:level).where(levels: { number: params[:level] })
      else
        scope
      end
    end

    def filter_students_by_name(scope)
      if params[:name].present?
        scope.joins(:user).where('users.name ILIKE ?', "%#{params[:name]}%")
      else
        scope
      end
    end

    def filter_students_by_email(scope)
      if params[:email].present?
        scope
          .joins(:user)
          .where('lower(users.email) ILIKE ?', "%#{params[:email].downcase}%")
      else
        scope
      end
    end

    def paginate_students(scope)
      scope.page(params[:page])
    end

    def sort_students(scope)
      case params[:sort_by]
      when 'Name'
        scope.joins(:user).order('users.name')
      when 'First Created'
        scope.order(created_at: :asc)
      when 'First Updated'
        scope.order(updated_at: :asc)
      when 'Last Updated'
        scope.order(updated_at: :desc)
      else
        scope.order(created_at: :desc)
      end
    end

    private

    def scope
      @scope ||=
        @organisation.founders.not_dropped_out.where(cohort_id: @cohort.id)
    end
  end
end
