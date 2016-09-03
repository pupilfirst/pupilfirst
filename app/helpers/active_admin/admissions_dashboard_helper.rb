module ActiveAdmin
  module AdmissionsDashboardHelper
    def paid_applicants_by_reference
      named_references = BatchApplicant.reference_sources - ['Other (Please Specify)']
      paid_applicants = BatchApplicant.for_batch_id_in(selected_batch_ids).conversion.where(reference: named_references).group(:reference).count
      paid_applicants_others_count = BatchApplicant.for_batch_id_in(selected_batch_ids).conversion.where.not(reference: named_references).count

      paid_applicants["Other"] = paid_applicants_others_count if paid_applicants_others_count.positive?
      paid_applicants.to_json
    end

    def paid_applications_by_location
      BatchApplication.where(batch_id: selected_batch_ids).payment_complete.joins(:university).group('universities.location').count.to_json
    end

    def paid_applications_by_date
      result = BatchApplication.where(batch_id: selected_batch_ids).payment_complete.joins(:payment).group_by_day('payments.paid_at').count.sort.to_h
      result.map { |k, v| [k.strftime('%b %d'), v] }.to_h.to_json
    end

    def paid_applications_by_team_size
      BatchApplication.where(batch_id: selected_batch_ids).payment_complete.group(:team_size).count.sort.to_h.to_json
    end

    def payment_completed_count
      BatchApplication.where(batch_id: selected_batch_ids).payment_complete.count
    end

    def payment_completed_delta
      BatchApplication.where(batch_id: selected_batch_ids).paid_today.count
    end

    def payment_initiated_count
      BatchApplication.where(batch_id: selected_batch_ids).payment_initiated.count
    end

    def payment_initiated_delta
      BatchApplication.where(batch_id: selected_batch_ids).payment_initiated_today.count
    end

    def submitted_application_count
      BatchApplication.where(batch_id: selected_batch_ids).submitted_application.count
    end

    def submitted_application_delta
      BatchApplication.where(batch_id: selected_batch_ids).submitted_application.where('batch_applications.created_at > ?', Time.now.beginning_of_day).count
    end

    def payment_completed_count_for(state)
      BatchApplication.where(batch_id: selected_batch_ids).payment_complete.from_state(state).count
    end

    def payment_completed_delta_for(state)
      BatchApplication.where(batch_id: selected_batch_ids).paid_today.from_state(state).count
    end

    def payment_completed_count_for_others
      BatchApplication.where(batch_id: selected_batch_ids).payment_complete.from_other_states.count
    end

    def payment_completed_delta_for_others
      BatchApplication.where(batch_id: selected_batch_ids).paid_today.from_other_states.count
    end

    def payment_initiated_count_for(state)
      BatchApplication.where(batch_id: selected_batch_ids).payment_initiated.from_state(state).count
    end

    def payment_initiated_delta_for(state)
      BatchApplication.where(batch_id: selected_batch_ids).payment_initiated_today.from_state(state).count
    end

    def payment_initiated_count_for_others
      BatchApplication.where(batch_id: selected_batch_ids).payment_initiated.from_other_states.count
    end

    def payment_initiated_delta_for_others
      BatchApplication.where(batch_id: selected_batch_ids).payment_initiated_today.from_other_states.count
    end

    def submitted_application_count_for(state)
      BatchApplication.where(batch_id: selected_batch_ids).submitted_application.from_state(state).count
    end

    def submitted_application_delta_for(state)
      BatchApplication.where(batch_id: selected_batch_ids).submitted_application.where('batch_applications.created_at > ?', Time.now.beginning_of_day).from_state(state).count
    end

    def submitted_application_count_for_others
      BatchApplication.where(batch_id: selected_batch_ids).submitted_application.from_other_states.count
    end

    def submitted_application_delta_for_others
      BatchApplication.where(batch_id: selected_batch_ids).submitted_application.where('batch_applications.created_at > ?', Time.now.beginning_of_day).from_other_states.count
    end

    def total_applications_count
      BatchApplication.where(batch_id: selected_batch_ids).count
    end

    def total_applicants_count
      BatchApplication.where(batch_id: selected_batch_ids).sum(:team_size) + BatchApplication.where(batch_id: selected_batch_ids, team_size: nil).count
    end

    def total_universities_count
      University.joins(:batch_applications).where(batch_applications: { batch: selected_batch_ids }).uniq.count
    end

    def total_location_count
      University.joins(:batch_applications).where(batch_applications: { batch: selected_batch_ids }).group(:location).count.count
    end

    def unique_visits_count
      start_time = Time.parse 'August 1, 2016, 00:00:00+0530'
      end_time = Time.now
      Visit.where(started_at: start_time..end_time).count
    end

    def conversion_percentage_for(state)
      total = BatchApplication.where(batch_id: selected_batch_ids).from_state(state).count
      return 0 unless total.positive?
      (payment_completed_count_for(state).to_f / total) * 100
    end

    def conversion_percentage_for_others
      total = BatchApplication.where(batch_id: selected_batch_ids).from_other_states.count
      return 0 unless total.positive?
      (payment_completed_count_for_others.to_f / total) * 100
    end
  end
end
