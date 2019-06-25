class DeleteContentBlockMutator < ApplicationMutator
  include AuthorizeSchoolAdmin
  attr_accessor :id

  validates :id, presence: true
  validate :not_the_only_content_block

  def delete_content_block
    content_block = ContentBlock.find(id)
    content_block.destroy!
  end

  def not_the_only_content_block
    return unless content_block.target.content_blocks.one?

    errors[:base] << 'Target must have at-least one content block'
  end

  def content_block
    @content_block ||= ContentBlock.find(id)
  end
end
