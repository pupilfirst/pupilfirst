module CourseExports
  class PrepareTeamsExportService
    include CourseExportable

    def execute
      tables = [
        { title: 'Targets', rows: target_rows },
        { title: 'Teams', rows: team_rows },
        { title: 'Submissions', rows: submission_rows },
      ]

      finalize(tables)
    end

    private

    def target_rows
      values = team_targets.map do |target|
        milestone = target.target_group.milestone ? 'Yes' : 'No'

        [
          target_id(target),
          target.level.number,
          target.title,
          target_type(target),
          milestone,
          teams_with_submissions(target),
          teams_pending_review(target),
        ]
      end

      ([
        ['ID', 'Level', 'Name', 'Completion Method', 'Milestone?', 'Teams with submissions', 'Teams pending review'],
      ] + values).transpose
    end

    def team_rows
      rows = teams.map do |team|
        [
          team.id,
          team.name,
          team.level.number,
          team.founders.map(&:name).sort.join(', '),
          team.faculty.map(&:name).sort.join(', '),
          team.tags.order(:name).pluck(:name).join(', '),
        ]
      end

      [['ID', 'Team Name', 'Level', 'Students', 'Coaches', 'Tags']] + rows
    end

    def submission_rows
      team_ids = teams.pluck(:id)

      values = team_targets.map do |target|
        grading = compute_grading_for_submissions(target, team_ids)
        [target_id(target)] + grading
      end

      ([
        ['Team ID'] + team_ids,
        ['Team Name'] + teams.pluck(:name),
      ] + values).transpose
    end

    def compute_grading_for_submissions(target, team_ids)
      submissions(target).order(:created_at).distinct.each_with_object(Array.new(team_ids.length)) do |submission, grading|
        team = submission.founders.first.startup

        next unless submission.founder_ids.sort == team.founder_ids.sort

        grade_index = team_ids.index(team.id)

        # We can't record grades for teams that have dropped out / aren't active.
        next if grade_index.nil?

        assign_styled_grade(grade_index, grading, submission)
      end
    end

    def team_targets
      targets(role: Target::ROLE_TEAM)
    end

    def submissions(target)
      target.timeline_events
        .joins(:founders)
        .where(founders: { id: student_ids })
    end

    def teams_with_submissions(target)
      submissions(target)
        .distinct('founders.startup_id')
        .count('founders.startup_id')
    end

    def teams_pending_review(target)
      target.timeline_events
        .pending_review
        .joins(:founders)
        .where(founders: { id: student_ids })
        .distinct('founders.startup_id')
        .count('founders.startup_id')
    end

    def teams
      # Only scan 'active' teams. Also filter by tag, if applicable.
      @teams ||= begin
          scope = Startup.includes(:level, :founders, faculty: :user)
            .joins(:course)
            .where(courses: { id: course.id }).active
            .order(:id).distinct

          tags.present? ? scope.tagged_with(tags, any: true) : scope
        end
    end

    def student_ids
      @student_ids ||= Founder.where(startup_id: teams.pluck(:id))
    end
  end
end
