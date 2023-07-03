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
          { key: "name", label: "Name", filterType: "Search", color: "red" },
          {
            key: "email",
            label: "Email",
            filterType: "Search",
            color: "yellow"
          },
          {
            key: "milestone",
            label: "Milestone",
            filterType: "MultiSelect",
            values:
              @course
                .targets
                .live
                .where(milestone: true)
                .order(:milestone_number)
                .map do |target|
                  "M#{target.milestone_number}: #{target.title}"
                end,
            color: "blue"
          },
          {
            key: "course",
            label: "Course",
            filterType: "MultiSelect",
            values: ["Completed", "Not Completed"],
            color: "green"
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
          filter_1 = filter_students_by_milestone(scope)
          filter_2 = filter_students_by_name(filter_1)
          filter_3 = filter_students_by_email(filter_2)
          filter_4 = filter_students_by_course_completion(filter_3)
          sorted = sort_students(filter_4)
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
          TimelineEvent.from_founders(scope).where(target: target).passed
        students_count = submissions.map(&:founders).flatten.uniq.count
        percentage = ((students_count / total_students_count.to_f) * 100).round
        status[target] = {
          percentage: percentage,
          students_count: students_count
        }
      end

      status
    end

    def total_students_count
      @total_students_count ||= scope.count
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

    def filter_students_by_milestone(scope)
      if params[:milestone].present?
        milestone_number = params[:milestone].split(":").first[1..-1]
        scope
          .joins(timeline_events: :target)
          .where(
            targets: {
              milestone_number: milestone_number,
              milestone: true
            }
          )
          .where.not(timeline_events: { passed_at: nil })
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
