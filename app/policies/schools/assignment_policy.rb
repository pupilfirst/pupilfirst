module Schools
  class AssignmentPolicy < ApplicationPolicy
    def update_milestone_number?
      Schools::CoursePolicy.new(@pundit_user, record.course).curriculum?
    end
  end
end
