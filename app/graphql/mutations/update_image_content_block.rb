module Mutations
  class UpdateImageContentBlock < GraphQL::Schema::Mutation
    argument :id, ID, required: true
    argument :caption, String, required: false
    argument :width, Types::ImageWidthType, required: true
    description 'Updates the caption and the width of an image block.'

    field :content_block, Types::ContentBlockType, null: true

    def resolve(params)
      mutator = UpdateImageContentBlockMutator.new(context, params)

      content_block = if mutator.valid?
          mutator.update_image_content_block
        else
          mutator.notify_errors
          nil
        end

      { content_block: content_block }
    end
  end
end
