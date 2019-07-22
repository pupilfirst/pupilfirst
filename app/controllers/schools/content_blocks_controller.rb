module Schools
  class ContentBlocksController < SchoolsController
    before_action :authorize_target

    # POST /school/target_groups/:target_group_id/targets(.:format)
    def create
      form = ::Schools::Targets::CreateContentBlockForm.new(ContentBlock.new)

      if form.validate(content_block_params)
        content_block = form.save(content_block_params)
        render json: content_block_data(content_block)
      else
        render json: { error: form.errors.full_messages.join(', ') }
      end
    end

    protected

    def authorize_target
      authorize(Target.find(params[:target_id]), policy_class: Schools::TargetPolicy)
    end

    def content_block_data(content_block)
      content_block_data = { id: content_block.id.to_s, content: content_block.content, error: nil }
      content_block.file.attached? ? content_block_data.merge(fileUrl: url_for(content_block.file)) : content_block_data
    end

    def content_block_params
      params[:content_block].merge(target_id: params[:target_id], content_sort_indices: JSON.parse(params[:content_sort_indices]))
    end
  end
end
