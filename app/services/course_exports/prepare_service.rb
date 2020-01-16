module CourseExports
  class PrepareService
    def initialize(course_export)
      @course_export = course_export
    end

    def execute
      spreadsheet = RODF::Spreadsheet.new
      add_custom_styles(spreadsheet)

      tables.each do |table|
        spreadsheet.table(table[:title]) do |rodf_table|
          rodf_table.add_rows table[:rows]
        end
      end

      io = StringIO.new(spreadsheet.bytes)

      @course_export.json_data = tables.to_json
      @course_export.file.attach(io: io, filename: filename, content_type: 'application/vnd.oasis.opendocument.spreadsheet')
      @course_export.save!
    end

    def tables
      @tables ||= [
        { title: 'Targets', rows: target_rows },
        { title: 'Students', rows: student_rows },
        { title: 'Submissions', rows: submission_rows }
      ]
    end

    private

    def course
      @course_export.course
    end

    def tags
      @course_export.tags.pluck(:name)
    end

    def add_custom_styles(spreadsheet)
      spreadsheet.office_style 'passing-grade', family: :cell do
        property :cell, 'background-color' => "#9AE6B4"
      end

      spreadsheet.office_style 'failing-grade', family: :cell do
        property :cell, 'background-color' => "#FEB2B2"
      end

      spreadsheet.office_style 'pending-grade', family: :cell do
        property :cell, 'background-color' => "#FAF089"
      end
    end

    def filename
      name = "#{course.name}-#{Time.zone.now.iso8601}".parameterize
      "#{name}.ods"
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

    def student_rows
      rows = students.map do |student|
        user = student.user

        [
          user.email,
          user.name,
          user.title,
          user.affiliation,
          student.tags.order(:name).pluck(:name).join(', ')
        ] + average_grades_for_student(student)
      end

      [['Email Address', 'Name', 'Title', 'Affiliation', 'Tags'] + evaluation_criteria_names] + rows
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

    # rubocop:disable Metrics/CyclomaticComplexity
    def compute_grading_for_submissions(student, target_ids)
      TimelineEvent.includes(:timeline_event_grades)
        .joins(:founders).where(founders: { id: student.id }).order(:created_at).distinct
        .each_with_object([]) do |submission, grading|
        grade_index = target_ids.index(submission.target_id)

        # We can't record grades for submissions where the target has been archived.
        next if grade_index.nil?

        evaluation_grade = submission.timeline_event_grades.pluck(:grade).join(',')

        grade, style = case [submission.passed_at.present?, evaluation_grade.empty?]
          when [true, true]
            [submission.quiz_score || '✓', '']
          when [true, false]
            [evaluation_grade, 'passing-grade']
          when [false, true]
            %w[RP pending-grade]
          when [false, false]
            [evaluation_grade, 'failing-grade']
        end

        append_grade(grading, grade_index, grade, style)
      end
    end

    # If a grade has already been stored, separate it from the next one with a semi-colon in the same cell.
    def append_grade(grading, grade_index, grade, style)
      # Store the grade as a number if we're not dealing with a complex grade.
      parsed_grade = begin
        integer_grade = grade.to_i
        integer_grade.to_s == grade ? integer_grade : grade
      end

      value = if grading[grade_index].present?
        "#{grading[grade_index][:value]};#{parsed_grade}"
      else
        parsed_grade
      end

      grading[grade_index] = if style.present?
        { value: value, style: style }
      else
        value
      end

      grading
    end

    # rubocop:enable Metrics/CyclomaticComplexity

    def students
      @students ||= begin
        # Only scan 'active' students. Also filter by tag, if applicable.
        scope = course.founders.active.includes(:user)
        tags.present? ? scope.tagged_with(tags, any: true) : scope
      end.order('users.email')
    end

    def targets
      @targets ||= begin
        scope = course.targets.live
          .joins(:level)
          .includes(:level, :evaluation_criteria, :quiz, :target_group)

        scope = @course_export.reviewed_only ? scope.joins(:evaluation_criteria) : scope

        scope.order('levels.number ASC, target_groups.sort_index ASC, targets.sort_index ASC').load
      end
    end

    def target_id(target)
      "L#{target.level.number}T#{target.id}"
    end

    def target_type(target)
      if target.evaluation_criteria.present?
        'Graded'
      elsif target.quiz.present?
        'Take Quiz'
      elsif target.link_to_complete.present?
        'Visit Link'
      else
        'Mark as Complete'
      end
    end
  end
end
