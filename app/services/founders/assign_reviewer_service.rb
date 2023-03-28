module Founders
  class AssignReviewerService
    def initialize(student)
      @student = student
    end

    def assign(coach_ids)
      coaches_to_assign = @student.course.faculty.where(id: coach_ids)

      if coaches_to_assign.count != [coach_ids].flatten.count
        raise "All coaches must be assigned to the student's course"
      end

      FacultyFounderEnrollment.transaction do
        FacultyFounderEnrollment.where(founder: @student).destroy_all

        coaches_to_assign.each do |coach|
          FacultyFounderEnrollment.create!(faculty: coach, founder: @student)
        end
      end
    end
  end
end
