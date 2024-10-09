module CourseExports
  class PrepareTeamsExportService
    include CourseExportable

    def execute
      tables = [
        { title: "Targets", rows: target_rows },
        { title: "Teams", rows: team_rows },
        { title: "Submissions", rows: submission_rows }
      ]

      finalize(tables)
    end

    private

    def target_rows
      values =
        targets_with_team_assignments.where(assignments: { archived: false }).map do |target|
          milestone = milestone?(target)

          [
            target_id(target),
            target.level.number,
            target.title,
            target_type(target),
            milestone,
            teams_with_submissions(target),
            teams_pending_review(target)
          ]
        end

      (
        [
          [
            "ID",
            "Level",
            "Name",
            "Completion Method",
            "Milestone?",
            "Teams with submissions",
            "Teams pending review"
          ]
        ] + values
      ).transpose
    end

    def team_rows
      rows =
        teams.map do |team|
          [
            team.id,
            team.name,
            team.cohort.name,
            team.students.map(&:name).sort.join(", ")
          ]
        end

      [["ID", "Team Name", "Cohort", "Students"]] + rows
    end

    def submission_rows
      team_ids = teams.pluck(:id)

      values =
        targets_with_team_assignments.where(assignments: { archived: false }).map do |target|
          grading = compute_grading_for_submissions(target, team_ids)
          [target_id(target)] + grading
        end

      (
        [["Team ID"] + team_ids, ["Team Name"] + teams.pluck(:name)] + values
      ).transpose
    end

    def compute_grading_for_submissions(target, team_ids)
      submissions(target)
        .order(:created_at)
        .distinct
        .each_with_object(Array.new(team_ids.length)) do |submission, grading|
          team = submission.students.first.team

          next if team.blank?

          next unless submission.student_ids.sort == team.student_ids.sort

          grade_index = team_ids.index(team.id)

          # We can't record grades for teams that have dropped out / aren't active.
          next if grade_index.nil?

          assign_styled_grade(grade_index, grading, submission)
        end
    end

    def targets_with_team_assignments
      targets(role: Assignment::ROLE_TEAM)
    end

    def submissions(target)
      target
        .timeline_events
        .live
        .joins(:students)
        .where(students: { id: student_ids })
    end

    def teams_with_submissions(target)
      submissions(target).distinct("students.team_id").count("students.team_id")
    end

    def teams_pending_review(target)
      target
        .timeline_events
        .live
        .pending_review
        .joins(:students)
        .where(students: { id: student_ids })
        .distinct("students.team_id")
        .count("students.team_id")
    end

    def teams
      # Only scan 'active' teams. Also filter by tag, if applicable.
      @teams ||=
        begin
          scope =
            Team
              .includes(students: [faculty: :user])
              .joins(:cohort)
              .where(cohort: { course_id: course.id })
              .active
              .order(:id)
              .distinct

          scope = (@cohorts.present? ? scope.where(cohort: @cohorts) : scope)

          applicable_student_ids =
            course.students.tagged_with(tags, any: true).pluck(:id)
          if tags.present?
            scope.where(students: { id: applicable_student_ids })
          else
            scope
          end
        end
    end

    def student_ids
      @student_ids ||=
        if @cohorts.present?
          Student.where(team_id: teams.pluck(:id), cohort: @cohorts)
        else
          Student.where(team_id: teams.pluck(:id))
        end
    end
  end
end
