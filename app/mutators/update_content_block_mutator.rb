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
    ContentBlock.transaction do
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
      handle_content_version
    end
  end

  private

  def content_block
    @content_block ||= begin
      if latest_content_version.updated_at.to_date == Date.today
        current_content_block
      else
        new_content_block = current_content_block.dup
        new_content_block.save!
        new_content_block.file.attach(current_content_block.file.blob) if current_content_block.file.attached?
        new_content_block
      end
    end
  end

  def authorized?
    current_school_admin.present? || current_user.course_authors.where(course: content_block.target.level.course).exists?
  end

  def latest_content_version
    @latest_content_version ||= target.target_content_versions.order('updated_at desc').first
  end

  def target
    @target ||= current_content_block.target
  end

  def current_content_block
    @current_content_block ||= ContentBlock.find(id)
  end

  def handle_content_version
    return if latest_content_version.updated_at.to_date == Date.today

    updated_content_block_ids = latest_content_version.content_blocks - [id.to_i] + [content_block.id]
    target.target_content_versions.create!(content_blocks: updated_content_block_ids)
  end
end
