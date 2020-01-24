class DeleteContentBlockMutator < ApplicationQuery
  include AuthorizeAuthor
  include ContentBlockEditable

  property :id, validates: { presence: true }

  validate :not_the_only_content_block
  validate :only_delete_on_the_latest_version

  def delete_content_block
    ContentBlock.transaction do
      current_version.destroy!
      content_block.destroy!
    end
  end

  private

  def current_version
    @current_version ||= ContentVersion.where(content_block: content_block, version_on: latest_version_date).first
  end

  # TODO: This will be needed when target_versions is introduced.
  def only_delete_on_the_latest_version
    # return if content_block.target_version.version_at == latest_version.version_at
    # errors[:base] << 'You can only delete blocks in the current version.'
  end

  # TODO: This will have to be updated when target_versions is introduced.
  def not_the_only_content_block
    return unless ContentVersion.where(target: target, version_on: latest_version_date).one?

    errors[:base] << 'Target must have at least one content block'
  end
end
