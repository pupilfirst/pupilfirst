module CourseReports
  class PrepareService
    def initialize(course, user)
      @course = course
      @user = user
    end

    def execute
      spreadsheet = RODF::Spreadsheet.new

      spreadsheet.table 'Targets' do |table|
        populate_targets_table(table)
      end

      spreadsheet.table 'Students' do |table|
        populate_students_table(table)
      end

      spreadsheet.table 'Submissions' do |table|
        populate_submissions_table(table)
      end

      io = StringIO.new(spreadsheet.bytes)

      CourseReport.transaction do
        course_report = CourseReport.create!(course: @course, user: @user, token: SecureRandom.urlsafe_base64(32))
        course_report.file.attach(io: io, filename: filename, content_type: 'application/vnd.oasis.opendocument.spreadsheet')
        course_report
      end
    end

    private

    def filename
      name = "#{@course.name}-#{Time.zone.now.iso8601}".parameterize
      "#{name}.ods"
    end

    def populate_targets_table(table)
      target_rows = @course.targets.live.includes(:level, :evaluation_criteria, :quiz).map do |target|
        [target.id, target.level.number, target.title, target_type(target)]
      end

      sorted_target_rows = target_rows.sort_by { |data| data[1] }

      table.row do |row|
        row.add_cells ["ID", "Level", "Name", "Completion Method"]
      end

      table.add_rows(sorted_target_rows)
    end

    def populate_students_table(table)
      student_rows = @course.founders.includes(:tags, :user).map do |student|
        user = student.user
        [student.id, user.email, user.name, user.title, user.affiliation, student.tags.pluck(:name).join(', ')]
      end

      table.row do |row|
        row.add_cells ["ID", "Email Address", "Name", "Title", "Affiliation", "Tags"]
      end

      table.add_rows student_rows
    end

    def populate_submissions_table(table)
      # Lay out the target IDs.
      table.row do |row|
        row.cell 'Student ID / Target ID'
        row.add_cells target_ids
      end

      # Now populate status for each student.
      @course.founders.each do |student|
        grading = []

        TimelineEvent.where(latest: true).where.not(passed_at: nil).includes(:timeline_event_grades)
          .joins(:founders).where(founders: { id: student.id }).distinct.each do |submission|
          evaluation_grade = submission.timeline_event_grades.pluck(:grade).sum
          grade = evaluation_grade.zero? ? 0 : 1
          grade_index = target_ids.index(submission.target_id)

          next if grade_index.nil?

          grading[grade_index] = grade
        end

        table.row do |row|
          row.add_cells([student.id] + grading)
        end
      end
    end

    def target_ids
      @target_ids ||= @course.targets.live.joins(:level).order('levels.number ASC').pluck(:id)
    end

    def submissions
      @submissions ||= @course.timeline_events.includes(:timeline_event_grades).each_with_object({}) do |submission, cache|
        submission.founder_ids.each do |founder_id|
          cache[founder_id] ||= {}
          cache[founder_id][submission.target_id]
        end
      end
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
