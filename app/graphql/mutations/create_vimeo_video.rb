module Mutations
  class CreateVimeoVideo < GraphQL::Schema::Mutation
    argument :size, Integer, required: true

    description "Create vimeo upload uri"
    
    field :vimeo_video, Types::VimeoVideo, null: true

    def resolve(params)
      mutator = CreateVimeoVideoMutator.new(context, params)
    
      vimeo_video = if mutator.valid?
                      mutator.create_vimeo_video
                    else
                      mutator.notify_errors
                      nil
                    end
      { vimeo_video: vimeo_video }
    end
  end
end
