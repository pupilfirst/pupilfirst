class SchoolStatsResolver < ApplicationQuery
  def school_stats
    {
      students_count: current_school.students.count,
      coaches_count: current_school.faculty.count
    }
  end

  private

  def authorized?
    current_school && current_school_admin.present?
  end
end
