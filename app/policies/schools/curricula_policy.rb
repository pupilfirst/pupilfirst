module Schools
  class CurriculaPolicy < ApplicationPolicy
    def show?
      # All school admins can view the curricula
      CoursePolicy.new(@pundit_user, record).show?
    end
  end
end
