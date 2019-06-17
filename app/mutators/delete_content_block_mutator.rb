class DeleteContentBlockMutator < ApplicationMutator
  include AuthorizeSchoolAdmin
  attr_accessor :id

  validates :id, presence: true

  def delete_content_block
    content_block = ContentBlock.find(id)
    content_block.destroy!
  end
end
