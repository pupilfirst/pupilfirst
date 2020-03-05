module Schools
  class CourseAuthorPolicy < ApplicationPolicy
    def show?
      Schools::CoursePolicy.new(@pundit_user, record.course).authors?
    end

    alias new? show?
  end
end
