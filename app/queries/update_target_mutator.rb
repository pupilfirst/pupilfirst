class UpdateTargetMutator < ApplicationQuery
  include AuthorizeAuthor

  property :id, validates: { presence: true }
  property :title, validates: { presence: true, length: { minimum: 1, maximum: 250 } }
  property :target_group_id, validates: { presence: true }
  property :role, validates: { presence: true, inclusion: { in: Target.valid_roles } }
  property :prerequisite_targets
  property :evaluation_criteria
  property :quiz
  property :completion_instructions
  property :link_to_complete
  property :visibility, validates: { presence: true, inclusion: { in: Target.valid_visibility_types } }

  validate :target_group_exists
  validate :target_exists
  validate :only_one_method_of_completion

  def target_group_exists
    errors[:base] << 'Target group does not exist' if target_group.blank?
  end

  def target_exists
    errors[:base] << 'Target does not exist' if target.blank?
  end

  def only_one_method_of_completion
    completion_criteria = [evaluation_criteria.present?, link_to_complete.present?, quiz.present?]

    return if completion_criteria.one? || completion_criteria.none?

    errors[:base] << 'More than one method of completion'
  end

  def update
    ::Targets::UpdateService.new(target).execute(target_params)
  end

  private

  def target_group
    @target_group ||= target.target_group
  end

  def target
    @target ||= current_school.targets.where(id: id).first
  end

  def course
    @course ||= target_group.course
  end

  def target_params
    {
      role: role,
      title: title,
      visibility: visibility,
      target_group_id: target_group_id,
      prerequisite_target_ids: prerequisite_targets,
      evaluation_criterion_ids: evaluation_criteria,
      quiz: quiz,
      link_to_complete: link_to_complete,
      completion_instructions: completion_instructions
    }
  end
end
