class PopulateContentBlocks < ActiveRecord::Migration[5.2]
  def youtube_embed_code(video_id)
    <<~YOUTUBE_EMBED_CODE
      <iframe width="640" height="360" src="https://www.youtube.com/embed/#{video_id}?rel=0" frameborder="0" allowfullscreen>
      </iframe>
    YOUTUBE_EMBED_CODE
  end

  def up
    Target.all.each do |target|
      puts "Processing Target##{target.id}..."

      # Create a markdown block with all of the textual content.
      description_md = Kramdown::Document.new(target.description, input: 'html').to_kramdown

      completion_instructions_md = if target.completion_instructions.present?
        <<~COMPLETION_INTRUCTIONS
          ## Completion Instructions
          #{target.completion_instructions}
        COMPLETION_INTRUCTIONS
      else
        ''
      end

      link_resources = target.resources.where.not(link: [nil, '']).pluck(:title, :link)
      resource_url = target.resource_url.present? ? ["Main Reference", target.resource_url] : []
      additional_links = resource_url + link_resources

      links_md = if additional_links.any?
        <<~LINKS
          ## Reference Links
          #{additional_links.map { |l| "- [#{l[0]}](#{l[1]})" }.join("\n")}
        LINKS
      else
        ''
      end

      additional_md = ''
      additional_md += "You should be able to complete this target in #{target.days_to_complete} days. " if target.days_to_complete.present?
      additional_md += "This session is to be conducted at #{target.session_at.iso8601}. " if target.session_at.present?
      additional_md += "This session was last conducted at #{target.last_session_at.iso8601}. " if target.last_session_at.present?

      target.content_blocks.create!(
        block_type: ContentBlock::BLOCK_TYPE_MARKDOWN,
        content: { markdown: description_md + completion_instructions_md + links_md + additional_md },
        sort_index: 0
      )

      # Create embed blocks for all of the embeddable content.
      if target.slideshow_embed.present?
        target.content_blocks.create!(
          block_type: ContentBlock::BLOCK_TYPE_EMBED,
          content: {
            url: 'https://example.com/original_url_unavailable',
            embed_code: target.slideshow_embed
          },
          sort_index: 1
        )
      end

      if target.video_embed.present?
        target.content_blocks.create!(
          block_type: ContentBlock::BLOCK_TYPE_EMBED,
          content: {
            url: 'https://example.com/original_url_unavailable',
            embed_code: target.video_embed
          },
          sort_index: 2
        )
      end

      if target.youtube_video_id.present?
        target.content_blocks.create!(
          block_type: ContentBlock::BLOCK_TYPE_EMBED,
          content: {
            url: "https://www.youtube.com/watch?v=#{target.youtube_video_id}",
            embed_code: youtube_embed_code(target.youtube_video_id)
          },
          sort_index: 3
        )
      end

      # Create file blocks for all of the file resources.
      target.resources.with_attached_file.each do |resource|
        next unless resource.file.attached?

        content_block = target.content_blocks.create!(
          block_type: ContentBlock::BLOCK_TYPE_FILE,
          content: { title: resource.title },
          sort_index: 4
        )

        content_block.file.attach(resource.file.blob)
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
