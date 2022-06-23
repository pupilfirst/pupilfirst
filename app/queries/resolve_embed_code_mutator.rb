class ResolveEmbedCodeMutator < ApplicationQuery
  include AuthorizeAuthor
  property :content_block_id, validates: { presence: true }

  validate :must_be_embed_type_block

  def resolve
    #To:Do Change the implementation to use new mutator schema and remove this file
    ContentBlocks::ResolveEmbededCodeService.new(content_block).execute
  end

  def must_be_embed_type_block
    if content_block.present? &&
         content_block.block_type == ContentBlock::BLOCK_TYPE_EMBED
      return
    end

    errors.add(:base, 'Can only resolve embed-type content blocks')
  end

  def content_block
    @content_block ||= ContentBlock.find_by(id: content_block_id)
  end

  def resource_school
    course&.school
  end

  def course
    content_block&.target_version&.target&.course
  end
end
