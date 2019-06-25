class SortContentBlocksMutator < ApplicationMutator
  include AuthorizeSchoolAdmin

  attr_accessor :content_block_ids

  validates :content_block_ids, presence: true
  validate :must_belong_to_same_target

  def sort
    ::ContentBlocks::SortService.new(content_block_ids).execute
  end

  def must_belong_to_same_target
    return if ContentBlock.where(id: content_block_ids).pluck(:target_id).uniq.one?

    errors[:base] << 'Content blocks must belong to the same target'
  end
end
