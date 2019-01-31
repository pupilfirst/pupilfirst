class ResourcePolicy < ApplicationPolicy
  def show?
    scope.where(id: record.id).exists?
  end

  def download?
    show?
  end

  class Scope < Scope
    def resolve
      # Return nothing if visiting a PupilFirst page.
      return scope.none if current_school.blank?

      resources = scope.live.joins(course: :school)

      public_resources = resources.where(schools: { id: current_school }).where(public: true)

      # Return only public resources in current school if no founder is signed in.
      return public_resources if current_founder.blank?

      # Return public resources and private course resources where founder is member.
      public_resources.or(
        resources.where(courses: { id: current_founder.level.course }).where(public: false)
      )
    end

    def target_resource_ids(course)
      allowed_target_ids = course.targets.pluck(:id)

      TargetResource.where(target_id: allowed_target_ids).pluck(:resource_id)
    end
  end
end
