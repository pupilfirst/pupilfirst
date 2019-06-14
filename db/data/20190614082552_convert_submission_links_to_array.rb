class ConvertSubmissionLinksToArray < ActiveRecord::Migration[5.2]
  def up
    # This destructive action removes all link titles from all previous student submissions, because we're opting to make
    # the submission process simpler by _not_ asking for an additional datum (title for a link).

    TimelineEvent.all.each do |submission|
      next if submission.links.empty?
      links_array = submission.links.map { |l| l[:url] }
      submission.update!(links: links_array)
    end

    true
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
