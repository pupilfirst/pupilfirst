module Schools
  class ContentBlocksController < SchoolsController
    include CamelizeKeys
    include StringifyIds

    # POST /school/targets/:target_id/content_block
    def create
      target = Target.find(params[:target_id])
      authorize(target.level, policy_class: Schools::ContentBlockPolicy)

      form = ::Schools::Targets::CreateContentBlockForm.new(ContentBlock.new)

      if form.validate(params)
        render json: camelize_keys(stringify_ids(form.save.merge(error: nil)))
      else
        render json: { error: form.errors.full_messages.join(', ') }
      end
    end

    protected

    def content_block_data(content_block)
      content_block_data = { id: content_block.id.to_s, content: content_block.content, error: nil }
      content_block.file.attached? ? content_block_data.merge!(fileUrl: url_for(content_block.file)) : content_block_data
      content_block_data.merge(versions: target_versions)
    end

    def target_versions
      Target.find(params[:target_id]).content_versions.order('version_on DESC').distinct(:version_on).pluck(:version_on)
    end
  end
end
