module Schools
  class CurriculaPolicy < ApplicationPolicy
    def show?
      # All school admins can access the curriculum editor (for now).
      true
    end
  end
end
