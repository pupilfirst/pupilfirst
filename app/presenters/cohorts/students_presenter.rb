module Cohorts
  class StudentsPresenter < ApplicationPresenter
    def initialize(view_context, organisation, cohort)
      @organisation = organisation
      @cohort = cohort
      super(view_context)
    end

    def filter
      @filter ||= {
        id: "organisation-cohort-students-filter",
        filters: [
          { key: "name", label: "Name", filterType: "Search", color: "red" },
          {
            key: "email",
            label: "Email",
            filterType: "Search",
            color: "yellow"
          }
        ],
        placeholder: "Search by name or email",
        hint: "...or start typing to search by student's name of email",
        sorter: {
          key: "sort_by",
          default: "Recently Seen",
          options: [
            "Recently Seen",
            "Name",
            "First Created",
            "Last Created",
            "Earliest Seen"
          ]
        }
      }
    end

    def counts
      @counts = {
        total: scope.count,
        completed: scope.where.not(completed_at: nil).count
      }
    end

    def students
      @students ||=
        begin
          filter_1 = filter_students_by_name(scope)
          filter_2 = filter_students_by_email(filter_1)
          sorted = sort_students(filter_2)
          included = sorted.includes(:user)
          paged = included.page(params[:page]).per(24)
          paged.count.zero? ? paged.page(paged.total_pages) : paged
        end
    end

    def milestone_completion_status
      milestone_targets =
        @cohort.course.targets.where(milestone: true).order(:milestone_number)

      status = {}

      milestone_targets.each do |target|
        submissions =
          TimelineEvent
            .from_founders(@cohort.founders)
            .where(target: target)
            .passed
        students_count = submissions.map(&:founders).flatten.uniq.count
        status[target] = (
          (students_count / total_students_count.to_f) * 100
        ).round
      end

      status
    end

    private

    def filter_students_by_name(scope)
      if params[:name].present?
        scope.joins(:user).where("users.name ILIKE ?", "%#{params[:name]}%")
      else
        scope
      end
    end

    def filter_students_by_email(scope)
      if params[:email].present?
        scope.joins(:user).where(
          "lower(users.email) ILIKE ?",
          "%#{params[:email].downcase}%"
        )
      else
        scope
      end
    end

    def sort_students(scope)
      case params[:sort_by]
      when "Name"
        scope.joins(:user).order("users.name")
      when "First Created"
        scope.order(created_at: :asc)
      when "Earliest Seen"
        scope.joins(:user).order("users.last_seen_at ASC NULLS FIRST")
      when "Last Created"
        scope.order(created_at: :desc)
      else
        scope.joins(:user).order("users.last_seen_at DESC NULLS LAST")
      end
    end

    def scope
      @scope ||=
        @organisation.founders.not_dropped_out.where(cohort_id: @cohort.id)
    end

    def total_students_count
      @total_students_count ||= scope.count
    end
  end
end
