module CourseExports
  class PrepareStudentsExportService
    include CourseExportable

    def execute
      tables = [
        { title: "Targets", rows: target_rows },
        { title: "Students", rows: student_rows },
        { title: "Submissions", rows: submission_rows },
      ]

      tables.push(PrepareUserStandingsExportService.new.execute(user_ids)) if @course_export.include_user_standings?

      finalize(tables)
    end

    private

    def target_rows
      values =
        targets.map do |target|
          milestone = milestone?(target)

          [
            target_id(target),
            target.level.number,
            target.title,
            target_type(target),
            milestone,
            students_with_submissions(target),
            submissions_pending_review(target)
          ] + average_grades_for_target(target)
        end

      (
        [
          [
            "ID",
            "Level",
            "Name",
            "Completion Method",
            "Milestone?",
            "Students with submissions",
            "Submissions pending review"
          ] + evaluation_criteria_names
        ] + values
      ).transpose
    end

    def evaluation_criteria_names
      @evaluation_criteria_names ||=
        EvaluationCriterion
          .where(id: evaluation_criteria_ids)
          .order(:name)
          .map { |ec| ec.display_name + " - Average" }
    end

    def evaluation_criteria_ids
      @evaluation_criteria_ids ||=
        targets
          .map do |target|
            assignment = target.assignments.not_archived.first
            if assignment
              assignment.evaluation_criteria.order(:name).pluck(:id)
            else
              []
            end
          end
          .flatten
          .uniq
    end

    def average_grades_for_target(target)
      empty_grades = Array.new(evaluation_criteria_ids.length)

      target
        .evaluation_criteria
        .pluck(:id)
        .each_with_object(empty_grades) do |evaluation_criterion_id, grades|
          average_grade =
            TimelineEventGrade
              .joins(timeline_event: :timeline_event_owners)
              .where(
                timeline_event_owners: {
                  latest: true,
                  student_id: students.pluck(:id)
                },
                timeline_events: {
                  target_id: target.id
                },
                evaluation_criterion_id: evaluation_criterion_id
              )
              .distinct
              .average(:grade)
              &.round(2)

          grades[
            evaluation_criteria_ids.index(evaluation_criterion_id)
          ] = average_grade
        end
    end

    def average_grades_for_student(student)
      evaluation_criteria_ids.map do |evaluation_criterion_id|
        TimelineEventGrade
          .joins(timeline_event: :timeline_event_owners)
          .where(
            timeline_event_owners: {
              latest: true,
              student_id: student.id
            },
            evaluation_criterion_id: evaluation_criterion_id
          )
          .distinct
          .average(:grade)
          &.round(2)
      end
    end

    def students_with_submissions(target)
      target
        .timeline_events
        .live
        .joins(:students)
        .where(students: { id: students.pluck(:id) })
        .distinct("students.id")
        .count("students.id")
    end

    def submissions_pending_review(target)
      target
        .timeline_events
        .live
        .pending_review
        .joins(:students)
        .where(students: { id: students.pluck(:id) })
        .distinct("timeline_events.id")
        .count
    end

    def report_path(student)
      @report_path_prefix ||=
        begin
          school = @course_export.user.school
          "https://#{school.domains.primary.fqdn}/students"
        end

      "#{@report_path_prefix}/#{student.id}/report"
    end

    def student_report_link(student)
      "oooc:=HYPERLINK(\"#{report_path(student)}\"; \"#{student.id}\")"
    end

    def latest_user_standing(user)
      user.user_standings.live.order(created_at: :desc).first
    end

    def school_default_standing(user)
      @school_default_standing ||= user.school.default_standing
    end

    def student_rows
      rows =
        students.map do |student|
          user = student.user

          [
            user.id,
            { formula: student_report_link(student) },
            user.email,
            user.name,
            user.title,
            user.affiliation,
            student.cohort.name,
            student.tags.order(:name).pluck(:name).join(", "),
            last_seen_at(user),
            student.completed_at&.iso8601 || "",
            latest_user_standing(user)&.standing&.name ||
              school_default_standing(user)&.name || "",
            latest_user_standing(user)&.reason ||
              school_default_standing(user)&.description || ""
          ] + average_grades_for_student(student)
        end

      [
        [
          "User ID",
          "Student ID",
          "Email Address",
          "Name",
          "Title",
          "Affiliation",
          "Cohort",
          "Tags",
          "Last Seen At",
          "Course Completed At",
          "Current Standing",
          "Current Standing Reason"
        ] + evaluation_criteria_names
      ] + rows
    end

    def submission_rows
      targets_with_assignments = targets.where(assignments: { archived: false })

      # Lay out the top row of target IDs.
      header =
        ["Student Email / Target ID"] +
        targets_with_assignments.map { |target| target_id(target) }

      target_ids = targets_with_assignments.pluck(:id)

      # Now populate status for each student.
      [header] +
        students.map do |student|
          grading = compute_grading_for_submissions(student, target_ids)
          [student.user.email] + grading
        end
    end

    def compute_grading_for_submissions(student, target_ids)
      TimelineEvent
        .live
        .includes(:timeline_event_grades)
        .joins(:students)
        .where(students: { id: student.id })
        .order(:created_at)
        .distinct
        .each_with_object([]) do |submission, grading|
          grade_index = target_ids.index(submission.target_id)

          # We can't record grades for submissions where the target has been archived.
          next if grade_index.nil?

          assign_styled_grade(grade_index, grading, submission)
        end
    end

    def students
      @students ||=
        begin
          scope =
            if @cohorts.present?
              Student.includes(:user).where(cohort: @cohorts)
            else
              course.students.includes(:user)
            end
          # Exclude inactive students, unless requested.
          scope =
            @course_export.include_inactive_students? ? scope : scope.active

          # Filter by tag, if applicable.
          tags.present? ? scope.tagged_with(tags, any: true) : scope
        end.order("users.email")
    end

    def last_seen_at(user)
      user.last_seen_at&.iso8601 || user.last_sign_in_at&.iso8601 || ""
    end

    def user_ids
      students.map(&:user_id)
    end
  end
end
