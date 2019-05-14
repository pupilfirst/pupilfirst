class ContentBlock < ApplicationRecord
  BLOCK_TYPE_MARKDOWN = -'markdown'
  BLOCK_TYPE_IMAGE = -'image'
  BLOCK_TYPE_EMBED = -'embed'
  BLOCK_TYPE_FILE = -'file'

  belongs_to :target

  has_one_attached :file

  def self.valid_block_types
    [BLOCK_TYPE_MARKDOWN, BLOCK_TYPE_IMAGE, BLOCK_TYPE_EMBED, BLOCK_TYPE_FILE]
  end

  validates :block_type, inclusion: { in: valid_block_types }
  validates :content, presence: true
  validates :sort_index, numericality: true, presence: true
end
