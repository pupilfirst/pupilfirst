module Cohorts
  class StudentsPresenter < ApplicationPresenter
    def initialize(view_context, cohort, organisation: nil)
      @organisation = organisation
      @course = cohort.course
      @cohort = cohort
      super(view_context)
    end

    def t(key, variables = {})
      I18n.t("presenters.cohorts.students.#{key}", **variables)
    end

    def filter
      @filter ||=
        begin
          targets_with_milestone_data =
            targets_with_milestone
              .pluck(:id, "assignments.milestone_number", :title)
              .map do |id, number, title|
                "#{id};#{I18n.t("presenters.cohorts.students.milestone_status_filter_value", m: I18n.t("shared.m"), number: number, title: title)}"
              end

          {
            id: "cohort-students-filter",
            filters: [
              {
                key: "milestone_completed",
                label: t("milestone_completed"),
                filterType: "MultiSelect",
                values: targets_with_milestone_data,
                color: "blue"
              },
              {
                key: "milestone_incomplete",
                label: t("milestone_incomplete"),
                filterType: "MultiSelect",
                values: targets_with_milestone_data,
                color: "orange"
              },
              {
                key: "course",
                label: t("course_completion"),
                filterType: "MultiSelect",
                values: %w[Completed Incomplete],
                color: "green"
              },
              {
                key: "name",
                label: t("search_by_name"),
                filterType: "Search",
                color: "red"
              },
              {
                key: "email",
                label: t("search_by_email"),
                filterType: "Search",
                color: "yellow"
              }
            ],
            placeholder: t("filter_placeholder"),
            hint: t("filter_hint"),
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
    end

    def counts
      @counts = {
        total: scope.count,
        completed: scope.where.not(completed_at: nil).count
      }
    end

    def filters_in_url
      params
        .slice(
          :name,
          :email,
          :milestone_completed,
          :milestone_incomplete,
          :course
        )
        .permit(
          :name,
          :email,
          :milestone_completed,
          :milestone_incomplete,
          :course
        )
        .compact
    end

    def students
      @students ||=
        begin
          filter_1 = filter_students_by_milestone_completed(scope)
          filter_2 = filter_students_by_milestone_incomplete(filter_1)
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
      status = Hash.new({ percentage: 0, students_count: 0 })

      TimelineEvent
        .from_students(scope)
        .where(target: targets_with_milestone)
        .passed
        .live
        .group(:target_id)
        .joins(:students)
        .select("target_id, COUNT(DISTINCT students.id) AS students_count")
        .each do |submission|
          target = targets_with_milestone.find { |t| t.id == submission.target_id }
          percentage =
            ((submission.students_count / counts[:total].to_f) * 100).round
          status[target.id] = {
            percentage: percentage,
            students_count: submission.students_count
          }
        end

      status
    end

    def targets_with_milestone
      @targets_with_milestone ||=
        @course.targets.live.milestone.order("assignments.milestone_number")
    end

    def page_title
      t("page_title", cohort_name: @cohort.name, course_name: @course.name)
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
        .joins(timeline_events: { target: :assignments })
        .where(targets: { id: param, assignments: { milestone: true } })
        .merge(TimelineEvent.passed)
        .merge(TimelineEvent.live)
    end

    def filter_students_by_milestone_completed(scope)
      if params[:milestone_completed].present?
        milestone_completed_students(params[:milestone_completed])
      else
        scope
      end
    end

    def filter_students_by_milestone_incomplete(scope)
      if params[:milestone_incomplete].present?
        scope.where.not(
          id: milestone_completed_students(params[:milestone_incomplete])
        )
      else
        scope
      end
    end

    def filter_students_by_course_completion(scope)
      if params[:course] == "Completed"
        scope.where.not(completed_at: nil)
      elsif params[:course] == "Incomplete"
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
      if @organisation.present?
        @scope ||=
          @organisation.students.not_dropped_out.where(cohort_id: @cohort.id)
      else
        @scope ||= @cohort.students.not_dropped_out
      end
    end
  end
end
