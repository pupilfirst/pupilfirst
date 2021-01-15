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
  validate :target_and_evaluation_criteria_have_same_course
  validate :prerequisite_targets_in_same_level
  validate :prerequisite_targets_not_archived
  validate :checklist_has_valid_data
  validate :checklist_within_allowed_length

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

  def prerequisite_targets_not_archived
    non_archived_targets = Target.where(id: prerequisite_targets).
      where.not(visibility: Target::VISIBILITY_ARCHIVED)

    return if non_archived_targets.count == prerequisite_targets.count

    errors[:base] << 'Cannot have archived prerequisites'
  end

  def target_exists
    errors[:base] << 'Target does not exist' if target.blank?
  end

  def only_one_method_of_completion
    completion_criteria = [evaluation_criteria.present?, link_to_complete.present?, quiz.present?]

    return if completion_criteria.one? || completion_criteria.none?

    errors[:base] << 'More than one method of completion'
  end

  def valid_string(string)
    string.is_a?(String) && string.strip.present?
  end

  def valid_checklist_kind(kind)
    kind.is_a?(String) && Target.valid_checklist_kind_types.include?(kind)
  end

  def valid_metadata(item)
    return true if item['kind'] != Target::CHECKLIST_KIND_MULTI_CHOICE && item['metadata'] == {}

    item['metadata']['choices'].length > 1 && item['metadata']['choices'].all? { |choice| valid_string(choice) }
  end

  def validate_checklist
    checklist.respond_to?(:all?) && checklist.all? do |item|
      valid_string(item['title']) && valid_checklist_kind(item['kind']) && (item['optional'] == !!item['optional']) && valid_metadata(item)
    end && checklist.select { |item| item['kind'] == Target::CHECKLIST_KIND_FILES }.count <= 1
  end

  def required_items_have_unique_titles
    required_items = checklist.reject { |item| item['optional'] }

    required_items.map { |item| item['title'].strip }.uniq.count == required_items.count
  end

  def checklist_has_valid_data
    return if evaluation_criteria.blank? && checklist.blank?

    return if evaluation_criteria.present? && validate_checklist && required_items_have_unique_titles

    errors[:checklist] << 'not a valid checklist'
  end

  def checklist_within_allowed_length
    return if checklist.respond_to?(:all?) && checklist.length <= 15

    errors[:checklist] << 'should have less than 15 items'
  end

  def update
    ::Targets::UpdateService.new(target).execute(target_params)
  end

  private

  def resource_school
    course&.school
  end

  def target_group
    @target_group ||= course.target_groups.where(id: target_group_id).first
  end

  def target
    @target ||= Target.find_by(id: id)
  end

  def course
    @course ||= target.course
  end

  def level
    @level ||= target_group.level
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
      completion_instructions: completion_instructions,
      checklist: checklist,
    }
  end
end
