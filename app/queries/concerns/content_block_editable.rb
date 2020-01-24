module ContentBlockEditable
  include ActiveSupport::Concern

  def course
    target.level.course if target.present?
  end

  def target
    @target ||= begin
      if content_block.present?
        content_block.latest_version.target
      end
    end
  end

  def content_block
    @content_block ||= ContentBlock.find_by(id: id)
  end

  def latest_version_date
    @latest_version_date ||= target.latest_content_version_date
  end
end
