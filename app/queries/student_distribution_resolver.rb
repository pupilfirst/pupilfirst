class StudentDistributionResolver < ApplicationQuery
  include AuthorizeReviewer

  property :course_id
  property :coach_id

  def student_distribution
    course.levels.map do |level|
      teams_in_level = level.startups.active

      coach_filtered = if coach_id.present?
        teams_in_level.joins(:faculty_startup_enrollments)
          .where("faculty_startup_enrollments.faculty_id = ?", coach_id)
      else
        teams_in_level
      end

      team_ids = coach_filtered.select(:id).distinct(:id)
      students_in_level = Founder.where(startup: team_ids).count
      teams_in_level = team_ids.count

      {
        id: level.id,
        number: level.number,
        students_in_level: students_in_level,
        teams_in_level: teams_in_level,
        unlocked: level.unlocked?
      }
    end
  end
end
