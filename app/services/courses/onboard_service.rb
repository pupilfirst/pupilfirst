module Courses
  class OnboardService
    def initialize(course, csv_rows)
      @course = course
      @csv_rows = csv_rows
    end

    def execute
      Course.transaction do
        students = @csv_rows.map do |row|
          tags = (row['tags'].presence || "").strip.split(',')
          OpenStruct.new(name: row['name'], email: row['email'], title: row['title'], affiliation: row['affiliation'], tags: tags, team_name: row['team_name'])
        end

        Courses::AddStudentsService.new(@course).add(students)
      end
    end
  end
end
