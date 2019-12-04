class CreateTargetMutator < ApplicationQuery
  property :title, validates: { presence: { message: 'TitleBlank' } }
  property :target_group_id, validates: { presence: { message: 'TargetGroupIdBlank' } }

  def create_target
    Target.transaction do
      target = Target.create!(title: title, target_group_id: target_group_id, role: Target::ROLE_STUDENT, target_action_type: Target::TYPE_TODO, visibility: Target::VISIBILITY_DRAFT, safe_to_change_visibility: true, sort_index: sort_index)
      demo_content_block_service = ContentBlocks::DemoMarkdownBlockService.new(target)
      content_block = demo_content_block_service.execute
      { id: target.id, content_block_id: content_block.id, sample_content: demo_content_block_service.content_block_text }
    end
  end

  private

  def sort_index
    max_index = TargetGroup.joins(:course).where(courses: { school_id: current_school.id }).find(target_group_id).targets.maximum(:sort_index)
    max_index ? max_index + 1 : 1
  end

  def authorized?
    current_school_admin.present? || current_user.course_authors.where(course: TargetGroup.find(target_group_id).level.course).exists?
  end
end
