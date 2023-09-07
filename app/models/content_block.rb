class ContentBlock < ApplicationRecord
  BLOCK_TYPE_MARKDOWN = -"markdown"
  BLOCK_TYPE_IMAGE = -"image"
  BLOCK_TYPE_EMBED = -"embed"
  BLOCK_TYPE_FILE = -"file"
  BLOCK_TYPE_AUDIO = -"audio"
  EMBED_REQUEST_SOURCE_VIMEO = -"VimeoUpload"

  has_one_attached :file
  belongs_to :target_version

  def self.valid_block_types
    [
      BLOCK_TYPE_MARKDOWN,
      BLOCK_TYPE_IMAGE,
      BLOCK_TYPE_EMBED,
      BLOCK_TYPE_FILE,
      BLOCK_TYPE_AUDIO
    ]
  end

  validates :block_type, inclusion: { in: valid_block_types }
  validates :content, presence: true
  validates_with RateLimitValidator, limit: 100, scope: :target_version_id

  def file?
    BLOCK_TYPE_FILE == block_type
  end

  def image?
    BLOCK_TYPE_IMAGE == block_type
  end

  def embed?
    BLOCK_TYPE_EMBED == block_type
  end

  def markdown?
    BLOCK_TYPE_MARKDOWN == block_type
  end
end
