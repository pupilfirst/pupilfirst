require 'csv'

module Courses
  class OnboardService
    def initialize(course, csv)
      @course = course
      @rows = CSV.parse(csv, headers: true)
    end

    def execute
      Course.transaction do
        students = @rows.map do |row|
          tags = (row['tags'].presence || "").strip.split(',')
          OpenStruct.new(name: row['name'], email: row['email'], title: row['title'], affiliation: row['affiliation'], tags: tags, team_name: row['team_name'])
        end

        Courses::AddStudentsService.new(@course).add(students)
      end
    end
  end
end
