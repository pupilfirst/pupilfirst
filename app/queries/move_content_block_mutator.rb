class MoveContentBlockMutator < ApplicationQuery
  include ContentBlockEditable
  include AuthorizeAuthor

  property :id, validates: { presence: true }
  property :direction, validates: { presence: true, inclusion: %w[Up Down] }

  # TODO: Update this method when target_versions table is introduced.
  def move_content_block
    ContentBlock.transaction do
      versions = ContentVersion.where(version_on: latest_version_date).order(sort_index: :ASC).to_a

      direction == 'Up' ? swap_up(versions, content_version) : swap_down(versions, content_version)

      versions.each_with_index do |version, index|
        version.update!(sort_index: index)
      end
    end
  end

  private

  def content_version
    @content_version ||= content_block.content_versions.find_by(version_on: latest_version_date)
  end

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
