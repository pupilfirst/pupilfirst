class SortContentBlocksMutator < ApplicationMutator
  attr_accessor :content_block_ids

  validates :content_block_ids, presence: true

  def sort
    ::ContentBlocks::SortService.new(content_block_ids).execute
  end

  private

  def target
    ContentBlock.find(content_block_ids.first).target
  end

  def authorized?
    current_school_admin.present? || current_user.course_authors.where(course: target.level.course).exists?
  end
end
