module Cohorts
  class OnboardService
    def initialize(cohort, csv_rows, notify_students: false)
      @cohort = cohort
      @csv_rows = csv_rows
      @notify_students = notify_students
    end

    def execute
      Cohort.transaction do
        students =
          @csv_rows.map do |row|
            tags = (row["tags"].presence || "").strip.split(",")
            OpenStruct.new(
              name: row["name"],
              email: row["email"],
              title: row["title"],
              affiliation: row["affiliation"],
              tags: tags,
              team_name: row["team_name"]
            )
          end

        Cohorts::AddStudentsService.new(@cohort, notify: @notify_students).add(
          students
        )
      end
    end
  end
end
