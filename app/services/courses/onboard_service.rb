module Courses
  class OnboardService
    def initialize(course, csv_rows, notify_students: false)
      @course = course
      @csv_rows = csv_rows
      @notify_students = notify_students
    end

    def execute
      Course.transaction do
        students = @csv_rows.map do |row|
          tags = (row['tags'].presence || "").strip.split(',')
          OpenStruct.new(name: row['name'], email: row['email'], title: row['title'], affiliation: row['affiliation'], tags: tags, team_name: row['team_name'])
        end

        Courses::AddStudentsService.new(@course, notify: @notify_students).add(students)
      end
    end
  end
end
