module Schools
  class StartupPolicy < ApplicationPolicy
    class Scope < Scope
      def resolve
        current_school.startups
      end
    end
  end
end
