class CreateTargetMutator < ApplicationQuery
  property :title, validates: { presence: { message: 'TitleBlank' } }
  property :target_group_id, validates: { presence: { message: 'TargetGroupIdBlank' } }

  def create_target
    Target.transaction do
      target = target_group.targets.create!(
        title: title,
        role: Target::ROLE_STUDENT,
        target_action_type: Target::TYPE_TODO,
        visibility: Target::VISIBILITY_DRAFT,
        safe_to_change_visibility: true,
        sort_index: sort_index,
      )

      demo_content_block_service = ContentBlocks::DemoMarkdownBlockService.new(target)
      content_block = demo_content_block_service.execute

      {
        id: target.id,
        content_block_id: content_block.id,
        sample_content: demo_content_block_service.content_block_text,
      }
    end
  end

  private

  def authorized?
    return false if target_group&.course&.school != current_school

    current_school_admin.present? || current_user.course_authors.exists?(course: target_group.course)
  end

  def target_group
    @target_group ||= TargetGroup.find_by(id: target_group_id)
  end

  def sort_index
    max_index = TargetGroup.joins(:course).where(courses: { school_id: current_school.id }).find(target_group_id).targets.maximum(:sort_index)
    max_index ? max_index + 1 : 1
  end
end
