module ContentBlockCreatable
  include ActiveSupport::Concern

  def course
    @course ||= target.level.course if target.present?
  end

  def target
    @target ||= Target.find_by(id: target_id)
  end

  def latest_version_date
    @latest_version_date ||= target.latest_content_version_date
  end

  def above_content_block
    @above_content_block ||= begin
      target.content_blocks.find_by(id: above_content_block_id) if above_content_block_id.present?
    end
  end
end
