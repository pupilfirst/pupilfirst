class DeleteContentBlockMutator < ApplicationMutator
  attr_accessor :id

  validates :id, presence: true
  validate :not_the_only_content_block

  def delete_content_block
    ContentBlock.transaction do
      if latest_content_version.updated_at.to_date == Date.today
        content_block.destroy!
        latest_content_version.content_blocks -= [id.to_i]
        latest_content_version.save!
      else
        new_version = latest_content_version.dup
        new_version.content_blocks -= [id.to_i]
        new_version.save!
      end
    end
  end

  def not_the_only_content_block
    return unless content_block.target.content_blocks.one?

    errors[:base] << 'Target must have at-least one content block'
  end

  def content_block
    @content_block ||= ContentBlock.find(id)
  end

  private

  def authorized?
    current_school_admin.present? || current_user.course_authors.where(course: content_block.target.level.course).exists?
  end

  def target
    @target ||= content_block.target
  end

  def latest_content_version
    @latest_content_version ||= target.target_content_versions.order('updated_at desc').first
  end
end
