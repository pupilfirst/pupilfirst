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

    def sort_content_blocks(content_sort_indices)
      content_sort_indices.each do |id, sort_index|
        next if id == 'new'

        ContentBlock.find(id).update!(sort_index: sort_index.to_i)
      end
    end

    def latest_content_version
      @latest_content_version ||= @target.target_content_versions.order('updated_at desc').first
    end

    def handle_content_version(content_sort_indices, new_content_block)
      if latest_content_version.present? && latest_content_version.updated_at.to_date == Date.today
        sort_content_blocks(content_sort_indices)
        latest_content_version.content_blocks << new_content_block.id
        latest_content_version.save!
      else
        create_new_content_version(content_sort_indices, new_content_block)
      end
    end

    def create_new_content_version(content_sort_indices, new_content_block)
      new_version_content_ids = [new_content_block.id]

      # Create a copy of the existing blocks with new sort index
      content_sort_indices.each do |id, sort_index|
        next if id == 'new'

        current_block = ContentBlock.find(id)
        copied_block = current_block.dup
        copied_block.save!
        copied_block.update!(sort_index: sort_index)
        copied_block.file.attach(current_block.file.blob) if current_block.file.attached?
        new_version_content_ids << copied_block.id
      end

      @target.target_content_versions.create!(content_blocks: new_version_content_ids)
    end
  end
end
