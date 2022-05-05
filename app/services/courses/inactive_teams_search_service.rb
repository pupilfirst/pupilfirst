module Courses
  class InactiveTeamsSearchService
    def initialize(course)
      @course = course
    end

    def find_teams(term)
      inactive_teams = Startup.inactive.joins(:course).where(courses: { id: @course }).joins(founders: :user)
      query_words = term.split
      query_words.each do |query|
        inactive_teams = inactive_teams.where('startups.name ILIKE ?', "%#{query}%").or(inactive_teams.where('users.name ILIKE ?', "%#{term}%"))
      end
      inactive_teams.distinct
    end
  end
end
