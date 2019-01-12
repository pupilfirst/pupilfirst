module Schools
  class CurriculaPolicy < ApplicationPolicy
    def show?
      # All school admins can access the curriculum editor of open courses
      !record.ended?
    end
  end
end
