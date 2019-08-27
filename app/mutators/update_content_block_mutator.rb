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
      handle_content_version
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
  end

  private

  def content_block
    @content_block ||= begin
      if target.latest_content_version_date == Date.today
        current_content_block.created_at.to_date == Date.today ? current_content_block : duplicate_block(current_content_block)
      else
        duplicate_block(current_content_block)
      end
    end
  end

  def authorized?
    current_school_admin.present? || current_user.course_authors.where(course: target.level.course).exists?
  end

  def target
    @target ||= current_content_block.content_versions.last.target
  end

  def current_content_block
    @current_content_block ||= ContentBlock.find(id)
  end

  def duplicate_block(current_block)
    new_content_block = current_block.dup
    new_content_block.save!
    new_content_block.file.attach(current_content_block.file.blob) if current_content_block.file.attached?
    new_content_block
  end

  def handle_content_version
    latest_version_date = target.latest_content_version_date

    if latest_version_date == Date.today
      sort_index = ContentVersion.where(content_block_id: id, version_on: latest_version_date).last.sort_index
      target.content_versions.where(content_block: content_block, version_on: Date.today, sort_index: sort_index).first_or_create!
      target.content_versions.where(content_block: current_content_block, version_on: Date.today).first.destroy! unless current_content_block.created_at.to_date == Date.today
    else
      create_new_version(latest_version_date)
    end
  end

  def create_new_version(last_version_date)
    previous_version = target.content_versions.where(version_on: last_version_date)
    previous_version.each do |content_version|
      next if content_version.content_block_id == id.to_i

      target.content_versions.create!(content_block_id: content_version.content_block_id, version_on: Date.today, sort_index: content_version.sort_index)
    end
    new_content_block_index = ContentVersion.where(content_block_id: id, version_on: last_version_date).last.sort_index
    target.content_versions.create!(content_block: content_block, version_on: Date.today, sort_index: new_content_block_index)
  end
end
