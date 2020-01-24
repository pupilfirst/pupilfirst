class ContentBlock < ApplicationRecord
  BLOCK_TYPE_MARKDOWN = -'markdown'
  BLOCK_TYPE_IMAGE = -'image'
  BLOCK_TYPE_EMBED = -'embed'
  BLOCK_TYPE_FILE = -'file'

  has_one_attached :file
  has_many :content_versions, dependent: :restrict_with_error

  def self.valid_block_types
    [BLOCK_TYPE_MARKDOWN, BLOCK_TYPE_IMAGE, BLOCK_TYPE_EMBED, BLOCK_TYPE_FILE]
  end

  validates :block_type, inclusion: { in: valid_block_types }
  validates :content, presence: true

  # TODO: Fix this when new target_versions table is introduced.
  def latest_version
    content_versions.order(version_on: :DESC).first
  end
end
