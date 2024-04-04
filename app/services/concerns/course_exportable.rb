module CourseExportable
  extend ActiveSupport::Concern

  def initialize(course_export)
    @course_export = course_export
    @cohorts = course_export.cohorts

    add_custom_styles
  end

  def finalize(tables)
    tables.each do |table|
      spreadsheet.table(table[:title]) do |rodf_table|
        rodf_table.add_rows table[:rows]
      end
    end

    io = StringIO.new(spreadsheet.bytes)

    @course_export.json_data = tables.to_json
    @course_export.file.attach(
      io: io,
      filename: filename,
      content_type: "application/vnd.oasis.opendocument.spreadsheet"
    )
    @course_export.save!
  end

  def spreadsheet
    @spreadsheet ||= RODF::Spreadsheet.new
  end

  def add_custom_styles
    spreadsheet.office_style "passing-grade", family: :cell do
      property :cell, "background-color" => "#9AE6B4"
    end

    spreadsheet.office_style "failing-grade", family: :cell do
      property :cell, "background-color" => "#FEB2B2"
    end

    spreadsheet.office_style "pending-grade", family: :cell do
      property :cell, "background-color" => "#FAF089"
    end
  end

  def course
    @course_export.course
  end

  def filename
    name = "#{course.name}-#{Time.zone.now.iso8601}".parameterize
    "#{name}.ods"
  end

  def assign_styled_grade(grade_index, grading, submission)
    evaluation_grade = submission.timeline_event_grades.pluck(:grade).join(",")

    # Determine the grade and style based on submission and evaluation status
    grade, style =
      case [submission.passed?, evaluation_grade.present?]
      when [true, true]
        # Case when the submission has passed and there is an evaluation grade
        # Use the evaluation grade and mark it as a passing grade
        [evaluation_grade, "passing-grade"]
      when [true, false]
        # Case when the submission has passed and there is no evaluation grade
        # Use the quiz score as the grade, or a checkmark if the score is not available
        [submission.quiz_score || "✓", "default"]
      when [false, false]
        if submission.evaluated?
          # Case when the submission has not passed, but has been evaluated
          # Mark it as failing
          %w[x failing-grade]
        else
          # Case when the submission has not passed and has not been evaluated
          # Mark it as pending grading
          %w[RP pending-grade]
        end
      when [false, true]
        # Case when the submission has not passed and there is an evaluation grade
        # This should be impossible - submissions can be graded only after they're accepted; crash if this happens
        raise "Submission #{submission.id} responded `false` to `#passed?` but has one or more evaluation grades"
      end

    append_grade(grading, grade_index, grade, style)
  end

  # If a grade has already been stored, separate it from the next one with a semi-colon in the same cell.
  def append_grade(grading, grade_index, grade, style)
    # Store the grade as a number if we're not dealing with a complex grade.
    parsed_grade =
      begin
        integer_grade = grade.to_i
        integer_grade.to_s == grade ? integer_grade : grade
      end

    value =
      if grading[grade_index].present?
        "#{grading[grade_index][:value]};#{parsed_grade}"
      else
        parsed_grade
      end

    grading[grade_index] = { value: value, style: style }

    grading
  end

  def targets(role: nil)
    @targets ||=
      begin
        scope =
          course.targets.live.includes(
            :level,
            :target_group,
            assignments: %i[quiz evaluation_criteria]
          )

        scope =
          case role
          when Assignment::ROLE_STUDENT
            scope.where(assignments: { role: Assignment::ROLE_STUDENT })
          when Assignment::ROLE_TEAM
            scope.where(assignments: { role: Assignment::ROLE_TEAM })
          else
            scope
          end

        scope =
          (
            if @course_export.reviewed_only
              scope.where.not(assignments: { evaluation_criteria: { id: nil } })
            else
              scope
            end
          )

        scope.order(
          "levels.number ASC, target_groups.sort_index ASC, targets.sort_index ASC"
        ).load
      end
  end

  def target_id(target)
    "L#{target.level.number}T#{target.id}"
  end

  def target_type(target)
    assignment = target.assignments.not_archived.first
    if assignment
      if assignment.evaluation_criteria.present?
        "Graded"
      elsif assignment.quiz.present?
        "Take Quiz"
      elsif assignment.checklist.present?
        "Submit Form"
      else
        "Mark as Read"
      end
    else
      "Mark as Read"
    end
  end

  def milestone?(target)
    assignment = target.assignments.not_archived.first
    if assignment
      assignment.milestone? ? "Yes" : "No"
    else
      "No"
    end
  end

  def tags
    @course_export.tags.pluck(:name)
  end
end
