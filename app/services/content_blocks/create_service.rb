module ContentBlocks
  class CreateService
    def initialize(target, params)
      @target = target
      @params = params
    end

    def execute
      ContentBlock.transaction do
        content_block = ContentBlock.create!(block_type: @params[:block_type], content: content)
        if @params[:file].present?
          content_block.file.attach(@params[:file])
        end
        handle_content_version(@params[:content_sort_indices], content_block)
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
        else
          raise "Encountered unexpected block_type when creating content block: #{block_type}"
      end
    end

    def embed_code
      Oembed::Resolver.new(@params[:url]).embed_code
    end

    def sort_content_blocks(content_sort_indices, new_content_block)
      content_sort_indices.each do |id, sort_index|
        if id == 'new'
          ContentVersion.create!(target: @target, content_block: new_content_block, version_on: Date.today, sort_index: sort_index)
        else
          ContentVersion.where(content_block_id: id, target_id: @target.id, version_on: Date.today).first.update!(sort_index: sort_index)
        end
      end
    end

    def latest_content_version_date
      @latest_content_version_date ||= @target.latest_content_version_date
    end

    def handle_content_version(content_sort_indices, new_content_block)
      if latest_content_version_date.present? && latest_content_version_date == Date.today
        sort_content_blocks(content_sort_indices, new_content_block)
      else
        create_new_content_version(content_sort_indices, new_content_block)
      end
    end

    def create_new_content_version(content_sort_indices, new_content_block)
      content_sort_indices.each do |id, sort_index|
        if id == 'new'
          ContentVersion.create!(content_block_id: new_content_block.id, target: @target, version_on: Date.today, sort_index: sort_index)
        else
          ContentVersion.create!(content_block_id: id, target: @target, version_on: Date.today, sort_index: sort_index)
        end
      end
    end
  end
end
