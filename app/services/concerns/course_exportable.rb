module CourseExportable
  extend ActiveSupport::Concern

  def initialize(course_export)
    @course_export = course_export

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
    @course_export.file.attach(io: io, filename: filename, content_type: 'application/vnd.oasis.opendocument.spreadsheet')
    @course_export.save!
  end

  def spreadsheet
    @spreadsheet ||= RODF::Spreadsheet.new
  end

  def add_custom_styles
    spreadsheet.office_style 'passing-grade', family: :cell do
      property :cell, 'background-color' => '#9AE6B4'
    end

    spreadsheet.office_style 'failing-grade', family: :cell do
      property :cell, 'background-color' => '#FEB2B2'
    end

    spreadsheet.office_style 'pending-grade', family: :cell do
      property :cell, 'background-color' => '#FAF089'
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

  def targets(role: nil)
    @targets ||= begin
        scope = course.targets.live
          .joins(:level)
          .includes(:level, :evaluation_criteria, :quiz, :target_group)

        scope = case role
          when Target::ROLE_STUDENT
            scope.student
          when Target::ROLE_TEAM
            scope.team
          else
            scope
          end

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

  def tags
    @course_export.tags.pluck(:name)
  end
end
