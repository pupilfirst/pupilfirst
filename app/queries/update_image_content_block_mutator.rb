class UpdateImageContentBlockMutator < ApplicationQuery
  include AuthorizeAuthor
  include ContentBlockEditable

  property :id, validates: { presence: true }
  property :caption, validates: { length: { maximum: 250 } }
  property :width, validate: { presence: true }
  validate :must_be_an_image_block
  validate :must_be_latest_version

  def update_image_content_block
    content_block.update!(content: { caption: caption.strip, width: width })
    target_version.touch # rubocop:disable Rails/SkipsModelValidations
    json_attributes
  end

  private

  def must_be_an_image_block
    return if content_block.image?

    errors[:base] << 'This is not an image block'
  end
end
