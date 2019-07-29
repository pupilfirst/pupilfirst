class DeleteContentBlockMutator < ApplicationMutator
  attr_accessor :id

  validates :id, presence: true
  validate :not_the_only_content_block

  def delete_content_block
    content_block.destroy!
  end

  def not_the_only_content_block
    return unless content_block.target.content_blocks.one?

    errors[:base] << 'Target must have at-least one content block'
  end

  def content_block
    @content_block ||= ContentBlock.find(id)
  end

  private

  def authorized?
    current_school_admin.present? || current_user.course_authors.where(course: content_block.target.level.course).exists?
  end
end
