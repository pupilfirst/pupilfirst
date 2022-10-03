class AddCompletedAtToFounders < ActiveRecord::Migration[6.1]
  def up
    add_column :founders, :completed_at, :datetime

    Founder.all.each do |founder|
      # Get the latest submission for the founder.
      latest_submission =
        founder.latest_submissions.order('created_at DESC').first

      # If the founder has no submissions, skip.
      if latest_submission.present? &&
           TimelineEvents::WasLastTargetService.new(latest_submission)
             .was_last_target?
        # If the founder has a submission, and it was the last target, set the
        founder.update!(completed_at: latest_submission.created_at)
      end
    end
  end

  def down
    remove_column :founders, :completed_at
  end
end
