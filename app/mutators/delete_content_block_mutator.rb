class DeleteContentBlockMutator < ApplicationMutator
  attr_accessor :id

  validates :id, presence: true

  def delete_content_block
    ContentBlock.transaction do
      if latest_version_date == Date.today
        content_block.created_at == Date.today ? content_block.destroy! : ContentVersion.where(content_block_id: id, version_on: Date.today).first.destroy!
      else
        handle_new_version
      end
    end
  end

  def content_block
    @content_block ||= ContentBlock.find(id)
  end

  private

  def authorized?
    current_school_admin.present? || current_user.course_authors.where(course: target.level.course).exists?
  end

  def target
    @target ||= ContentVersion.where(content_block_id: id).last.target
  end

  def latest_version_date
    @latest_version_date ||= content_block.content_versions.maximum(:version_on)
  end

  def handle_new_version
    target.content_versions.where(version_on: latest_version_date).each do |version|
      next if version.content_block_id == id.to_i

      ContentVersion.create!(target: target, content_block: version.content_block, version_on: Date.today, sort_index: version.sort_index)
    end
  end
end
