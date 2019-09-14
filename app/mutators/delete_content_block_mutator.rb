class DeleteContentBlockMutator < ApplicationMutator
  attr_accessor :id

  validates :id, presence: true
  validate :not_the_only_content_block

  def delete_content_block
    ContentBlock.transaction do
      if latest_version_date == Date.today
        ContentVersion.where(content_block_id: id, version_on: Date.today).first.destroy!
        content_block.destroy! if content_block.created_at.to_date == Date.today
      else
        handle_new_version
      end
    end
  end

  def not_the_only_content_block
    return unless ContentVersion.where(target: target, version_on: latest_version_date).one?

    errors[:base] << 'Target must have at-least one content block'
  end

  def current_version
    @current_version ||= ContentVersion.where(content_block: content_block, version_on: latest_version_date).first
  end

  def content_block
    @content_block ||= ContentBlock.find(id)
  end

  def target_versions
    target.content_versions.order('version_on DESC').distinct(:version_on).pluck(:version_on)
  end

  private

  def delete_content_version
    current_version.destroy if latest_version_date == Date.today
  end

  def authorized?
    current_school_admin.present? || current_user.course_authors.where(course: target.level.course).exists?
  end

  def target
    @target ||= ContentVersion.where(content_block_id: id).last.target
  end

  def latest_version_date
    @latest_version_date ||= target.content_versions.maximum(:version_on)
  end

  def handle_new_version
    target.content_versions.where(version_on: latest_version_date).each do |version|
      next if version.content_block_id == id.to_i

      ContentVersion.create!(target: target, content_block: version.content_block, version_on: Date.today, sort_index: version.sort_index)
    end
  end
end
