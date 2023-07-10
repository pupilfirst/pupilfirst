module Cohorts
  class StudentsPresenter < ApplicationPresenter
    def initialize(view_context, organisation, cohort)
      @organisation = organisation
      @cohort = cohort
      @course = cohort.course
      super(view_context)
    end

    def filter
      @filter ||= {
        id: "organisation-cohort-students-filter",
        filters: [
          {
            key: "milestone_completed",
            label: "Milestone Completed",
            filterType: "MultiSelect",
            values:
              @course
                .targets
                .live
                .where(milestone: true)
                .order(:milestone_number)
                .map do |target|
                  "#{target.id};M#{target.milestone_number}: #{target.title}"
                end,
            color: "blue"
          },
          {
            key: "milestone_pending",
            label: "Milestone Pending",
            filterType: "MultiSelect",
            values:
              @course
                .targets
                .live
                .where(milestone: true)
                .order(:milestone_number)
                .map do |target|
                  "#{target.id};M#{target.milestone_number}: #{target.title}"
                end,
            color: "orange"
          },
          {
            key: "course",
            label: "Course",
            filterType: "MultiSelect",
            values: ["Completed", "Not Completed"],
            color: "green"
          },
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

    def filters_in_url
      params
        .slice(:name, :email, :milestone, :course)
        .permit(:name, :email, :milestone, :course)
        .compact
    end

    def students
      @students ||=
        begin
          filter_1 = filter_students_by_milestone_completed(scope)
          filter_2 = filter_students_by_milestone_pending(filter_1)
          filter_3 = filter_students_by_course_completion(filter_2)
          filter_4 = filter_students_by_name(filter_3)
          filter_5 = filter_students_by_email(filter_4)
          sorted = sort_students(filter_5)
          included = sorted.includes(:user)
          paged = included.page(params[:page]).per(24)
          paged.count.zero? ? paged.page(paged.total_pages) : paged
        end
    end

    def milestone_completion_status
      status =
        milestone_targets.index_with { { percentage: 0, students_count: 0 } }

      TimelineEvent
        .from_founders(scope)
        .where(target: milestone_targets)
        .passed
        .group(:target_id)
        .joins(:founders)
        .select("target_id, COUNT(DISTINCT founders.id) AS students_count")
        .each do |submission|
          target = milestone_targets.find { |t| t.id == submission.target_id }
          percentage =
            (
              (submission.students_count / total_students_count.to_f) * 100
            ).round
          status[target] = {
            percentage: percentage,
            students_count: submission.students_count
          }
        end

      status
    end

    def total_students_count
      @total_students_count ||= scope.count
    end

    def milestone_targets
      @milestone_targets ||=
        @course.targets.live.where(milestone: true).order(:milestone_number)
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

    def milestone_completed_students(param)
      scope
        .joins(timeline_events: :target)
        .where(targets: { id: param, milestone: true })
        .where.not(timeline_events: { passed_at: nil })
    end

    def filter_students_by_milestone_completed(scope)
      if params[:milestone_completed].present?
        milestone_completed_students(params[:milestone_completed])
      else
        scope
      end
    end

    def filter_students_by_milestone_pending(scope)
      if params[:milestone_pending].present?
        scope.where.not(
          id: milestone_completed_students(params[:milestone_pending])
        )
      else
        scope
      end
    end

    def filter_students_by_course_completion(scope)
      if params[:course] == "Completed"
        scope.where.not(completed_at: nil)
      elsif params[:course] == "Not Completed"
        scope.where(completed_at: nil)
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
  end
end
