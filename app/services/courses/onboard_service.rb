require 'csv'
require 'open-uri'

module Courses
  class OnboardService
    def initialize(course, file_link)
      @course = course
      @file_link = file_link
    end

    def execute
      csv_text = URI.open(@file_link)
      csv = CSV.parse(csv_text, headers: true)

      students = csv.map do |row|
        OpenStruct.new(name: row['Name'], email: row['Email'], title: row['Title'], affiliation: row['Affiliation'], tags: row['Tags'], team_name: row['TeamName'])
      end

      Courses::AddStudentsService.new(@course).execute(students)
    end
  end
end
