module Mutations
  class CreateVimeoVideo < GraphQL::Schema::Mutation
    argument :target_id, ID, required: true
    argument :size, Integer, required: true
    argument :title, String, required: false
    argument :description, String, required: false

    description "Create Vimeo upload URI"

    field :vimeo_video, Types::VimeoVideo, null: true

    def resolve(params)
      mutator = CreateVimeoVideoMutator.new(context, params)

      vimeo_video = if mutator.valid?
        mutator.create_vimeo_video
      else
        nil
      end

      mutator.notify_errors if vimeo_video.blank?

      { vimeo_video: vimeo_video }
    end
  end
end
