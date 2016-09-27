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
      total_applications: total_applications_count,
      total_applicants: total_applicants_count,
      total_universities: total_universities_count,
      total_states: total_location_count,
      total_visits: unique_visits_count,
      paid_applications: paid_applications_count,
      paid_applications_today: paid_applications_today,
      payment_initiated: payment_initiated_count,
      payment_initiated_today: payment_initiated_today,
      submitted_applications: submitted_applications_count,
      submitted_applications_today: submitted_applications_today,
      state_wise_stats: focused_states_stats.merge(other_states_stats)
    }
  end

  private

  def selected_applications
    BatchApplication.where(batch_id: selected_batch_ids)
  end

  def total_applications_count
    selected_applications.count
  end

  def total_applicants_count
    selected_applications.sum(:team_size) + BatchApplication.where(batch_id: selected_batch_ids, team_size: nil).count
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
    selected_applications.payment_complete.count
  end

  def paid_applications_today
    selected_applications.paid_today.count
  end

  def payment_initiated_count
    selected_applications.payment_initiated.count
  end

  def payment_initiated_today
    selected_applications.payment_initiated_today.count
  end

  def submitted_applications_count
    selected_applications.submitted_application.count
  end

  def submitted_applications_today
    selected_applications.submitted_application.where('batch_applications.created_at > ?', Time.now.beginning_of_day).count
  end

  def focused_states_stats
    State.focused_for_admissions.each_with_object({}) do |state, states|
      states[state.name.to_sym] = {
        paid_applications: paid_applications_count_for(state),
        paid_applications_today: paid_applications_today_for(state),
        payment_initiated: payment_initiated_count_for(state),
        payment_initiated_today: payment_initiated_today_for(state),
        submitted_applications: submitted_applications_count_for(state),
        submitted_applications_today: submitted_applications_today_for(state),
        conversion_percentage: conversion_percentage_for(state)
      }
    end
  end

  def paid_applications_count_for(state)
    selected_applications.payment_complete.from_state(state).count
  end

  def paid_applications_today_for(state)
    selected_applications.paid_today.from_state(state).count
  end

  def payment_initiated_count_for(state)
    selected_applications.payment_initiated.from_state(state).count
  end

  def payment_initiated_today_for(state)
    selected_applications.payment_initiated_today.from_state(state).count
  end

  def submitted_applications_count_for(state)
    selected_applications.submitted_application.from_state(state).count
  end

  def submitted_applications_today_for(state)
    selected_applications.submitted_application.where('batch_applications.created_at > ?', Time.now.beginning_of_day).from_state(state).count
  end

  def conversion_percentage_for(state)
    total = selected_applications.from_state(state).count
    return 0 unless total.positive?
    (paid_applications_count_for(state).to_f / total) * 100
  end

  def other_states_stats
    {
      Others:
        {
          paid_applications: paid_applications_count_for_others,
          paid_applications_today: paid_applications_today_for_others,
          payment_initiated: payment_initiated_count_for_others,
          payment_initiated_today: payment_initiated_today_for_others,
          submitted_applications: submitted_applications_count_for_others,
          submitted_applications_today: submitted_applications_today_for_others,
          conversion_percentage: conversion_percentage_for_others
        }
    }
  end

  def paid_applications_count_for_others
    selected_applications.payment_complete.from_other_states.count
  end

  def paid_applications_today_for_others
    selected_applications.paid_today.from_other_states.count
  end

  def payment_initiated_count_for_others
    selected_applications.payment_initiated.from_other_states.count
  end

  def payment_initiated_today_for_others
    selected_applications.payment_initiated_today.from_other_states.count
  end

  def submitted_applications_count_for_others
    selected_applications.submitted_application.from_other_states.count
  end

  def submitted_applications_today_for_others
    selected_applications.submitted_application.where('batch_applications.created_at > ?', Time.now.beginning_of_day).from_other_states.count
  end

  def conversion_percentage_for_others
    total = selected_applications.from_other_states.count
    return 0 unless total.positive?
    (payment_completed_count_for_others.to_f / total) * 100
  end
end
