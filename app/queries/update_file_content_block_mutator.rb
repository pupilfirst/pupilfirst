class UpdateFileContentBlockMutator < ApplicationQuery
  include AuthorizeAuthor
  include ContentBlockEditable

  property :id, validates: { presence: true }
  property :title, validates: { length: { maximum: 60 } }

  validate :must_be_a_file_block
  validate :must_be_latest_version

  def update_file_content_block
    content_block.update!(content: { title: title.strip })
    target_version.touch # rubocop:disable Rails/SkipsModelValidations
    json_attributes
  end

  private

  def must_be_a_file_block
    return if content_block.file?

    errors[:base] << 'This is not a file block'
  end
end
