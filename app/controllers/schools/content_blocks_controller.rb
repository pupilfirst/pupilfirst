module Schools
  class ContentBlocksController < SchoolsController
    include CamelizeKeys
    include StringifyIds

    # POST /school/targets/:target_id/content_block
    def create
      target = Target.find(params[:target_id])

      # Let's authorize against the level, since that's the resource we have with a matching action in the policy.
      authorize(target.level, policy_class: Schools::LevelPolicy)

      form = ::Schools::Targets::CreateContentBlockForm.new(ContentBlock.new)

      if form.validate(params)
        render json: camelize_keys(stringify_ids(form.save.merge(error: nil)))
      else
        render json: { error: form.errors.full_messages.join(', ') }
      end
    end
  end
end
