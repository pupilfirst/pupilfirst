class SeedSubmissionNumbers < ActiveRecord::Migration[6.1]
  def change
    @updated_submissions = Hash.new

    TimelineEvent.includes(:founders).each do |submission|
      next if @updated_submissions[submission.id]

      all_submissions = submissions(submission).order('timeline_events.created_at ASC').select do |s|
        s.timeline_event_owners.pluck(:founder_id).sort == student_ids(submission)
      end

      all_submissions.each_with_index do |s, index|
        s.update!(number: index)
        @updated_submissions[s.id] = true
      end
    end
  end

  def submissions(submission)
    TimelineEvent.where(target_id: submission.target_id).joins(:timeline_event_owners).where(timeline_event_owners: { founder_id: student_ids(submission) }).distinct
  end

  def student_ids(submission)
    submission.founders.pluck(:id).sort
  end
end
