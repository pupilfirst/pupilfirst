class ResourcePolicy < ApplicationPolicy
  def show?
    scope.where(id: record.id).exists?
  end

  def download?
    show?
  end

  def scope
    Pundit.policy_scope!(user, Resource.joins(:course))
  end

  class Scope < Scope
    def resolve
      # Public resources for the school.
      resources = scope.where(public: true)

      current_founder = user&.current_founder

      # Return public resources if current founder is not present
      return resources if current_founder.blank?

      startup = current_founder.startup

      # ...plus resources based on the startup's course...
      resources = resources.or(scope.where('course_id = ?', startup.course.id))

      # ...plus resources based on targets (for cloned courses)
      resources.or(scope.where(id: target_resource_ids(startup.course)))
    end

    def target_resource_ids(course)
      allowed_target_ids = course.targets.pluck(:id)

      TargetResource.where(target_id: allowed_target_ids).pluck(:resource_id)
    end
  end
end
