class MoveContentBlockMutator < ApplicationQuery
  include ContentBlockEditable
  include AuthorizeAuthor

  property :id, validates: { presence: true }
  property :direction, validates: { presence: true, inclusion: %w[Up Down] }

  def move_content_block
    ContentBlock.transaction do
      ordered_content_blocks = content_blocks.order(sort_index: :ASC) # Order the versions by current sort_index
        .to_a # We'll re-order the array...

      direction == 'Up' ? swap_up(ordered_content_blocks, content_block) : swap_down(ordered_content_blocks, content_block)

      # ...and then re-index the re-ordered array.
      ordered_content_blocks.each_with_index do |cb, index|
        cb.update!(sort_index: index)
      end

      target_version.touch # rubocop:disable Rails/SkipsModelValidations
    end
  end

  private

  def swap_up(array, element)
    index = array.index(element)

    return array if index.zero? || index.blank?

    element_above = array[index - 1]
    array[index - 1] = element
    array[index] = element_above
    array
  end

  def swap_down(array, element)
    index = array.index(element)
    swap_up(array, array[index + 1])
  end
end
