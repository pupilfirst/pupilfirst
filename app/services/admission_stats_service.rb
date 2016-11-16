class AdmissionStatsService
  attr_reader :selected_batch_ids

  # returns stats for all batches which have opened for applications
  def self.load_overall_stats
    new.load_stats(Batch.opened_for_applications.pluck(:id))
  end

  # return stats for the specified batch
  def self.load_stats(batch)
    new.load_stats([batch.id])
  end

  def load_stats(batch_ids)
    @selected_batch_ids = batch_ids

    {
      total_applications: total_applications,
      total_applicants: total_applicants,
      total_universities: total_universities,
      total_states: total_locations,
      total_visits: unique_visits,
      total_visits_today: unique_visits_today,
      paid_applications: paid_applications(:all),
      paid_from_earlier_batches: paid_from_earlier_batches,
      paid_applications_today: paid_applications_today(:all),
      payment_initiated: payment_initiated(:all),
      payment_initiated_today: payment_initiated_today(:all),
      submitted_applications: submitted_applications(:all),
      submitted_applications_today: submitted_applications_today(:all),
      top_references_today: top_references_today,
      state_wise_stats: focused_states_stats.merge(other_states_stats)
    }
  end

  private

  def focused_states_stats
    State.focused_for_admissions.each_with_object({}) do |state, states|
      states[state.name.to_sym] = {
        paid_applications: paid_applications(state),
        paid_applications_today: paid_applications_today(state),
        payment_initiated: payment_initiated(state),
        payment_initiated_today: payment_initiated_today(state),
        submitted_applications: submitted_applications(state),
        submitted_applications_today: submitted_applications_today(state),
        conversion_percentage: conversion_percentage(state)
      }
    end
  end

  def other_states_stats
    {
      Others:
        {
          paid_applications: paid_applications(:non_focused),
          paid_applications_today: paid_applications_today(:non_focused),
          payment_initiated: payment_initiated(:non_focused),
          payment_initiated_today: payment_initiated_today(:non_focused),
          submitted_applications: submitted_applications(:non_focused),
          submitted_applications_today: submitted_applications_today(:non_focused),
          conversion_percentage: conversion_percentage(:non_focused)
        }
    }
  end

  def selected_applications
    BatchApplication.where(batch_id: selected_batch_ids)
  end

  def total_applications
    selected_applications.count
  end

  def total_applicants
    selected_applications.sum(:team_size) + BatchApplication.where(batch_id: selected_batch_ids, team_size: nil).count
  end

  def total_universities
    # University.joins(:batch_applications).where(batch_applications: { batch: selected_batch_ids }).uniq.count
    ReplacementUniversity.joins(:batch_applications).where(batch_applications: { batch: selected_batch_ids }).distinct.count
  end

  def total_locations
    State.joins(:batch_applications).where(batch_applications: { batch: selected_batch_ids }).distinct.count
  end

  def unique_visits
    start_time = Time.parse 'August 1, 2016, 00:00:00+0530'
    end_time = Time.now
    Visit.where(started_at: start_time..end_time).count
  end

  def unique_visits_today
    start_time = 1.hour.ago.beginning_of_day # to be safe when invoked at midnight
    end_time = Time.now
    Visit.where(started_at: start_time..end_time).count
  end

  def paid_applications(state_scope)
    selected_applications.for_states(state_scope).payment_complete.count
  end

  # applications which were paid but for earlier batches
  def paid_from_earlier_batches
    return unless selected_batch_ids.length == 1 # can be calculated only if a single batch is specified

    selected_applications.payment_complete.where.not(swept_in_at: nil).count
  end

  def paid_applications_today(state_scope)
    selected_applications.for_states(state_scope).paid_today.count
  end

  def payment_initiated(state_scope)
    selected_applications.for_states(state_scope).payment_initiated.count
  end

  def payment_initiated_today(state_scope)
    selected_applications.for_states(state_scope).payment_initiated_today.count
  end

  def submitted_applications(state_scope)
    selected_applications.for_states(state_scope).submitted_application.count
  end

  def submitted_applications_today(state_scope)
    selected_applications.for_states(state_scope).submitted_application.where('batch_applications.created_at > ?', Time.now.beginning_of_day).count
  end

  def conversion_percentage(state_scope)
    total = selected_applications.for_states(state_scope).count
    return 0 unless total.positive?
    (paid_applications(state_scope).to_f / total) * 100
  end

  def top_references_today
    applicants_today = BatchApplicant.where('created_at > ?', Time.now.in_time_zone('Asia/Kolkata').beginning_of_day)

    applicants_today.group(:reference).count.sort_by(&:last).reverse[0..4]
  end
end
