module Students
  class AssignReviewerService
    def initialize(student)
      @student = student
    end

    def assign(coach_ids)
      coaches_to_assign = @student.course.faculty.where(id: coach_ids)

      if coaches_to_assign.count != [coach_ids].flatten.count
        raise "All coaches must be assigned to the student's course"
      end

      FacultyStudentEnrollment.transaction do
        FacultyStudentEnrollment.where(student: @student).destroy_all

        coaches_to_assign.each do |coach|
          FacultyStudentEnrollment.create!(faculty: coach, student: @student)
        end
      end
    end
  end
end
