class AdmissionStatsService
  attr_reader :selected_batch_ids

  def self.load_overall_stats
    new.load_stats(Batch.opened_for_applications.pluck(:id))
  end

  def self.load_stats(batch)
    new.load_stats([batch.id])
  end

  def load_stats(batch_ids)
    @selected_batch_ids = batch_ids

    {
      total_applications: total_applications_count,
      total_applicants: total_applicants_count,
      total_universities: total_universities_count,
      total_states: total_location_count,
      total_visits: unique_visits_count,
      paid_applications: paid_applications_count,
      paid_applications_today: payment_completed_today,
      payment_initiated: payment_initiated_count,
      payment_initiated_today: payment_initiated_today,
      submitted_applications: submitted_applications_count,
      submitted_applications_today: submitted_applications_today
    }
  end

  def total_applications_count
    BatchApplication.where(batch_id: selected_batch_ids).count
  end

  def total_applicants_count
    BatchApplication.where(batch_id: selected_batch_ids).sum(:team_size) + BatchApplication.where(batch_id: selected_batch_ids, team_size: nil).count
  end

  def total_universities_count
    # University.joins(:batch_applications).where(batch_applications: { batch: selected_batch_ids }).uniq.count
    ReplacementUniversity.joins(:batch_applications).where(batch_applications: { batch: selected_batch_ids }).distinct.count
  end

  def total_location_count
    # University.joins(:batch_applications).where(batch_applications: { batch: selected_batch_ids }).group(:location).count.count
    State.joins(:batch_applications).where(batch_applications: { batch: selected_batch_ids }).distinct.count
  end

  def unique_visits_count
    start_time = Time.parse 'August 1, 2016, 00:00:00+0530'
    end_time = Time.now
    Visit.where(started_at: start_time..end_time).count
  end

  def paid_applications_count
    BatchApplication.where(batch_id: selected_batch_ids).payment_complete.count
  end

  def payment_completed_today
    BatchApplication.where(batch_id: selected_batch_ids).paid_today.count
  end

  def payment_initiated_count
    BatchApplication.where(batch_id: selected_batch_ids).payment_initiated.count
  end

  def payment_initiated_today
    BatchApplication.where(batch_id: selected_batch_ids).payment_initiated_today.count
  end

  def submitted_applications_count
    BatchApplication.where(batch_id: selected_batch_ids).submitted_application.count
  end

  def submitted_applications_today
    BatchApplication.where(batch_id: selected_batch_ids).submitted_application.where('batch_applications.created_at > ?', Time.now.beginning_of_day).count
  end
end
