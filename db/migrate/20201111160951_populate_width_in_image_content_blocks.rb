class PopulateWidthInImageContentBlocks < ActiveRecord::Migration[6.0]
  class ContentBlock < ApplicationRecord
  end

  def up
    require_relative '../../lib/command_line_progress'

    scope = ContentBlock.where(block_type: 'image')
    clp = CommandLineProgress.new(scope.count)

    scope.each do |content_block|
      clp.tick
      updated_content = content_block.content.dup
      updated_content['width'] = 'Auto'
      content_block.update!(content: updated_content)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
