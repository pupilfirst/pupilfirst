class SortCurriculumResourceMutator < ApplicationMutator
  attr_accessor :resource_type
  attr_accessor :resource_ids

  validates :resource_ids, presence: true
  validates :resource_type, inclusion: { in: [TargetGroup.name, Target.name], message: 'InvalidResourceType' }
  validate :must_belong_to_same_parent

  def sort
    resource.transaction do
      resources.each do |resource|
        resource.update!(sort_index: resource_ids.index(resource.id.to_s))
      end
    end
  end

  def must_belong_to_same_parent
    return unless resource_type.in?([TargetGroup.name, Target.name])

    return if resources.pluck(parent_resource_identifier).uniq.one?

    errors[:base] << "#{resource_type} must belong to the same parent resource"
  end

  private

  def parent_resource_identifier
    case resource_type
      when TargetGroup.name
        :level_id
      when Target.name
        :target_group_id
      else
        raise 'InvalidResourceType'
    end
  end

  def resource
    case resource_type
      when TargetGroup.name
        TargetGroup
      when Target.name
        Target
      else
        raise 'InvalidResourceType'
    end
  end

  def resources
    @resources ||= begin
      case resource_type
        when TargetGroup.name
          current_school.target_groups.where(id: resource_ids)
        when Target.name
          current_school.targets.where(id: resource_ids)
        else
          []
      end
    end
  end

  def course
    resources.first.level.course
  end

  def authorized?
    current_school_admin.present? || current_user.course_authors.where(course: course).exists?
  end
end
