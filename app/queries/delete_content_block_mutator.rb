class DeleteContentBlockMutator < ApplicationQuery
  include AuthorizeAuthor
  include ContentBlockEditable

  property :id, validates: { presence: true }

  validate :not_the_only_content_block
  validate :must_be_latest_version

  def delete_content_block
    ContentBlock.transaction do
      content_block.destroy!
      target_version.touch # rubocop:disable Rails/SkipsModelValidations
    end
  end

  private

  def current_version
    @current_version ||= ContentVersion.where(content_block: content_block, version_on: latest_version_date).first
  end

  def not_the_only_content_block
    return unless content_blocks.one?

    errors[:base] << 'Target must have at least one content block'
  end
end
