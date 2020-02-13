class UpdateTargetMutator < ApplicationQuery
  include AuthorizeAuthor

  property :id, validates: { presence: true }
  property :title, validates: { presence: true, length: { minimum: 1, maximum: 250 } }
  property :target_group_id, validates: { presence: true }
  property :role, validates: { presence: true, inclusion: { in: Target.valid_roles } }
  property :prerequisite_targets
  property :evaluation_criteria
  property :quiz
  property :completion_instructions, validates: { length: { maximum: 1000 } }
  property :link_to_complete, validates: { url: true, allow_blank: true }
  property :visibility, validates: { presence: true, inclusion: { in: Target.valid_visibility_types } }
  property :checklist

  validate :target_group_exists
  validate :target_exists
  validate :only_one_method_of_completion
  validate :target_and_target_group_in_same_course
  validate :target_and_evaluation_criteria_have_same_course
  validate :prerequisite_targets_in_same_level

  def target_group_exists
    errors[:base] << 'Target group does not exist' if target_group.blank?
  end

  def target_and_evaluation_criteria_have_same_course
    return if course.evaluation_criteria.where(id: evaluation_criteria).count == evaluation_criteria.count

    errors[:base] << 'Evaluation criteria must be from the same course as the target'
  end

  def prerequisite_targets_in_same_level
    targets = level.targets.where(id: prerequisite_targets)

    return if targets.count == prerequisite_targets.count

    errors[:base] << 'Prerequisite targets must be from the same level as the target'
  end

  def target_exists
    errors[:base] << 'Target does not exist' if target.blank?
  end

  def only_one_method_of_completion
    completion_criteria = [evaluation_criteria.present?, link_to_complete.present?, quiz.present?]

    return if completion_criteria.one? || completion_criteria.none?

    errors[:base] << 'More than one method of completion'
  end

  def target_and_target_group_in_same_course
    return if target.course.id == target_group.course.id

    errors[:base] << 'target and target group not from the same course'
  end

  def update
    ::Targets::UpdateService.new(target).execute(target_params)
  end

  private

  def target_group
    @target_group ||= current_school.target_groups.where(id: target_group_id).first
  end

  def target
    @target ||= current_school.targets.where(id: id).first
  end

  def course
    @course ||= target.course
  end

  def level
    @level ||= target.level
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
