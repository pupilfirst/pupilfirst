class UpdateImageContentBlockMutator < ApplicationQuery
  include AuthorizeAuthor
  include ContentBlockEditable

  property :id, validates: { presence: true }
  property :caption, validates: { length: { maximum: 250 } }

  validate :must_be_an_image_block

  # TODO: Implement an equivalent of this when target_versions table is present.
  # validate :must_be_latest_version

  def update_image_content_block
    content_block.update!(content: { caption: caption.strip })
    json_attributes
  end

  private

  def must_be_an_image_block
    return if content_block.image?

    errors[:base] << 'This is not an image block'
  end
end
