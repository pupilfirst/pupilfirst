module Targets
  class CreateContentVersionService
    def initialize(target, above_content_block)
      @target = target
      @above_content_block = above_content_block
    end

    def create(content_block)
      # Move all content blocks at and below 'above_content_block' one step below.
      shift_content_blocks_below(sort_index)

      # Now create new content version and slot it into the old position of 'above_content_block'.
      content_version = create_content_version(content_block, sort_index)

      json_attributes(content_version, content_block)
    end

    private

    def json_attributes(content_version, content_block)
      attributes = content_block.attributes
        .slice('id', 'block_type', 'content')
        .merge(content_version.slice('sort_index'))
        .with_indifferent_access

      if content_block.file.attached?
        attributes.merge(
          fileUrl: Rails.application.routes.url_helpers.rails_blob_path(content_block.file, only_path: true),
          filename: content_block.file.filename.to_s
        )
      else
        attributes
      end
    end

    def shift_content_blocks_below(sort_index)
      ContentVersion.where(version_on: latest_version_date)
        .where('sort_index >= ?', sort_index)
        .update_all('sort_index = sort_index + 1') # rubocop:disable Rails/SkipsModelValidations
    end

    def sort_index
      @sort_index ||= begin
        if @above_content_block.present?
          # Put at the same position as 'above_content_block'.
          version_of_above_content_block.sort_index
        else
          # Put at the bottom.
          @target.content_versions.where(version_on: latest_version_date).maximum(:sort_index) + 1
        end
      end
    end

    def version_of_above_content_block
      @version_of_above_content_block ||= @above_content_block.content_versions.where(version_on: latest_version_date).first
    end

    def latest_version_date
      @latest_version_date ||= @target.latest_content_version_date
    end

    def create_content_version(content_block, sort_index)
      @target.content_versions.create!(
        content_block: content_block,
        version_on: latest_version_date,
        sort_index: sort_index
      )
    end
  end
end
