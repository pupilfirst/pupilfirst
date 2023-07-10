module Schools
  class AssignmentPolicy < ApplicationPolicy
    def update_milestone_number?
      record.course.school == current_school &&
        Schools::CoursePolicy.new(@pundit_user, record.course).curriculum?
    end
  end
end
