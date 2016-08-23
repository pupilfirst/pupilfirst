module ActiveAdmin
  module AdmissionsDashboardHelper
    def paid_applicants_by_reference
      named_references = BatchApplicant.reference_sources - ['Other (Please Specify)']
      paid_applicants = BatchApplicant.for_batch_id_in(selected_batch_ids).conversion.where(reference: named_references).group(:reference).count
      paid_applicants_others_count = BatchApplicant.for_batch_id_in(selected_batch_ids).conversion.where.not(reference: named_references).count

      paid_applicants["Other"] = paid_applicants_others_count if paid_applicants_others_count > 0
      paid_applicants.to_json
    end

    def paid_applications_by_location
      BatchApplication.where(batch_id: selected_batch_ids).payment_complete.joins(:university).group('universities.location').count.to_json
    end

    def paid_applications_by_date
      result = BatchApplication.where(batch_id: selected_batch_ids).payment_complete.joins(:payment).group("date_trunc('day', payments.paid_at)").count.sort.to_h
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

    def payment_initiated_count_for(state)
      BatchApplication.where(batch_id: selected_batch_ids).payment_initiated.from_state(state).count
    end

    def payment_initiated_delta_for(state)
      BatchApplication.where(batch_id: selected_batch_ids).payment_initiated_today.from_state(state).count
    end

    def submitted_application_count_for(state)
      BatchApplication.where(batch_id: selected_batch_ids).submitted_application.from_state(state).count
    end

    def submitted_application_delta_for(state)
      BatchApplication.where(batch_id: selected_batch_ids).submitted_application.where('batch_applications.created_at > ?', Time.now.beginning_of_day).from_state(state).count
    end
  end
end
