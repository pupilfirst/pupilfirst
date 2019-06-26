class UpdateContentBlockMutator < ApplicationMutator
  include AuthorizeSchoolAdmin
  attr_accessor :id
  attr_accessor :block_type
  attr_accessor :text

  validates :id, presence: true
  validates :block_type, presence: true
  validates :text, presence: true

  def update_content_block
    case block_type
      when 'markdown'
        content_block.update!(content: { markdown: text })
      when 'image'
        content_block.update!(content: { caption: text })
      when 'file'
        content_block.update!(content: { title: text })
      else
        raise 'Not a valid block type'
    end
  end

  private

  def content_block
    @content_block ||= ContentBlock.find(id)
  end
end
