class UpdateContentBlockMutator < ApplicationMutator
  include AuthorizeSchoolAdmin
  attr_accessor :id
  attr_accessor :block_type
  attr_accessor :text

  validates :id, presence: true
  validates :block_type, presence: true
  validate :text_must_be_present_for_markdown

  def text_must_be_present_for_markdown
    return if text.present?
    return if block_type.in? %w[image file]

    errors[:base] << 'Markdown content cannot be blank'
  end

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

  def authorized?
    current_school_admin.present? || current_user.course_authors.where(course: content_block.target.level.course).exists?
  end
end
