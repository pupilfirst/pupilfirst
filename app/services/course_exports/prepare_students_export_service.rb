module CourseExports
  class PrepareStudentsExportService
    include CourseExportable

    def execute
      tables = [
        { title: 'Targets', rows: target_rows },
        { title: 'Students', rows: student_rows },
        { title: 'Submissions', rows: submission_rows }
      ]

      finalize(tables)
    end

    private

    def tags
      @course_export.tags.pluck(:name)
    end

    def target_rows
      values = targets.map do |target|
        milestone = target.target_group.milestone ? 'Yes' : 'No'

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

      ([
        ['ID', 'Level', 'Name', 'Completion Method', 'Milestone?', 'Students with submissions', 'Submissions pending review'] + evaluation_criteria_names
      ] + values).transpose
    end

    def evaluation_criteria_names
      @evaluation_criteria_names ||= EvaluationCriterion.where(id: evaluation_criteria_ids).order(:name).map do |ec|
        ec.display_name + " - Average"
      end
    end

    def evaluation_criteria_ids
      @evaluation_criteria_ids ||= targets.map do |target|
        target.evaluation_criteria.order(:name).pluck(:id)
      end.flatten.uniq
    end

    def average_grades_for_target(target)
      empty_grades = Array.new(evaluation_criteria_ids.length)

      target.evaluation_criteria.pluck(:id).each_with_object(empty_grades) do |evaluation_criterion_id, grades|
        grades[evaluation_criteria_ids.index(evaluation_criterion_id)] = TimelineEventGrade.joins(timeline_event: :founders).where(timeline_events: { target_id: target.id, latest: true }, founders: { id: students.pluck(:id) }, evaluation_criterion_id: evaluation_criterion_id).distinct.average(:grade)&.round(2)
      end
    end

    def average_grades_for_student(student)
      evaluation_criteria_ids.map do |evaluation_criterion_id|
        TimelineEventGrade.joins(timeline_event: :founders).where(timeline_events: { latest: true }, founders: { id: student.id }, evaluation_criterion_id: evaluation_criterion_id).average(:grade)&.round(2)
      end
    end

    def students_with_submissions(target)
      target.timeline_events.joins(:founders).where(founders: { id: students.pluck(:id) }).distinct('founders.id').count('founders.id')
    end

    def submissions_pending_review(target)
      target.timeline_events.pending_review.joins(:founders).where(founders: { id: students.pluck(:id) }).distinct('timeline_events.id').count
    end

    def report_path(student)
      @report_path_prefix ||= begin
        school = @course_export.user.school
        "https://#{school.domains.primary.fqdn}/students"
      end

      "#{@report_path_prefix}/#{student.id}/report"
    end

    def student_report_link(student)
      "oooc:=HYPERLINK(\"#{report_path(student)}\"; \"#{student.id}\")"
    end

    def student_rows
      rows = students.map do |student|
        user = student.user

        [
          { formula: student_report_link(student) },
          user.email,
          user.name,
          user.title,
          user.affiliation,
          student.tags.order(:name).pluck(:name).join(', ')
        ] + average_grades_for_student(student)
      end

      [['ID', 'Email Address', 'Name', 'Title', 'Affiliation', 'Tags'] + evaluation_criteria_names] + rows
    end

    def submission_rows
      # Lay out the top row of target IDs.
      header = ['Student Email / Target ID'] + targets.map do |target|
        target_id(target)
      end

      target_ids = targets.pluck(:id)

      # Now populate status for each student.
      [header] + students.map do |student|
        grading = compute_grading_for_submissions(student, target_ids)
        [student.user.email] + grading
      end
    end

    def compute_grading_for_submissions(student, target_ids)
      TimelineEvent.includes(:timeline_event_grades)
        .joins(:founders).where(founders: { id: student.id }).order(:created_at).distinct
        .each_with_object([]) do |submission, grading|
        grade_index = target_ids.index(submission.target_id)

        # We can't record grades for submissions where the target has been archived.
        next if grade_index.nil?

        assign_styled_grade(grade_index, grading, submission)
      end
    end

    def students
      @students ||= begin
        # Only scan 'active' students. Also filter by tag, if applicable.
        scope = course.founders.active.includes(:user)
        tags.present? ? scope.tagged_with(tags, any: true) : scope
      end.order('users.email')
    end
  end
end
