module CourseExports
  class PrepareUserStandingsExportService
    def execute(students)
      @students = students

      { title: "Standing Logs", rows: user_standing_rows }
    end

    private

    def user_standing_rows
      rows =
        @students.flat_map do |student|
          user_standings = student.user.user_standings.includes(:standing).order(:created_at)
          if user_standings.present?
            user_standings.map do |user_standing|
              [
                user_standing.user_id,
                student.user.email,
                student.user.name,
                user_standing.standing.name,
                user_standing.created_at.iso8601,
                user_standing.creator.name,
                user_standing.reason,
                user_standing.archived_at&.iso8601
              ]
            end
          else
            []
          end
        end

      [
        [
          "User ID",
          "Email Address",
          "Name",
          "Standing Name",
          "Created At",
          "Creator Name",
          "Reason",
          "Archived at"
        ]
      ] + rows
    end
  end
end
