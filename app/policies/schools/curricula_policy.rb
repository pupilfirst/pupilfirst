module Schools
  class CurriculaPolicy < ApplicationPolicy
    def show?
      # All school admins can view the curricula
      true
    end
  end
end
