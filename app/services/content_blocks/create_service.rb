module ContentBlocks
  class CreateService
    def initialize(target, params)
      @target = target
      @params = params
    end

    def execute
      ContentBlock.transaction do
        content_block = @target.content_blocks.create!(sort_index: @params[:content_sort_indices]['new'].to_i, block_type: @params[:block_type], content: content)
        if @params[:file].present?
          content_block.file.attach(@params[:file])
        end
        sort_content_blocks(@params[:content_sort_indices])
        content_block
      end
    end

    private

    def content
      case @params[:block_type]
        when 'markdown'
          { markdown: @params[:markdown] }
        when 'image'
          { caption: @params[:caption] }
        when 'file'
          { title: @params[:title] }
        when 'embed'
          { url: @params[:url], embed_code: embed_code }
      end
    end

    def embed_code
      Oembed::Resolver.new(@params[:url]).embed_code
    end

    def sort_content_blocks(content_sort_indices)
      content_sort_indices.each do |id, sort_index|
        next if id == 'new'

        ContentBlock.find(id).update!(sort_index: sort_index.to_i)
      end
    end
  end
end
