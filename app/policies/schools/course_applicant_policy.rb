module Schools
  class CourseApplicantPolicy < ApplicationPolicy
    def show?
      Schools::CoursePolicy.new(@pundit_user, record.course).authors?
    end

    alias details? show?
    alias actions? show?
  end
end
