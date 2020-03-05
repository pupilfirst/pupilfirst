require 'csv'
require 'open-uri'

module Courses
  class OnboardService
    def initialize(course, csv)
      @course = course
      @rows = CSV.parse(csv, headers: true)
    end

    def execute
      Course.transaction do
        students = @rows.map do |row|
          OpenStruct.new(name: row['name'], email: row['email'], title: row['title'], affiliation: row['affiliation'], tags: row['tags'], team_name: row['team_name'])
        end

        Courses::AddStudentsService.new(@course).execute(students)
      end
    end
  end
end
