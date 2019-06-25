module ContentBlocks
  class CreateService
    def initialize(target, params)
      @target = target
      @params = params
    end

    def execute
      content_block = ContentBlock.create!(target: @target, sort_index: @params[:sort_index], block_type: @params[:block_type], content: content)
      if @params[:file].present?
        content_block.file.attach(@params[:file])
      end
      content_block
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
  end
end
