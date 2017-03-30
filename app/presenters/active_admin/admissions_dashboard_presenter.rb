module ActiveAdmin
  class AdmissionsDashboardPresenter
    attr_reader :stats, :selected_round_ids

    def initialize(application_round_id)
      @stats = application_round_id.present? ? AdmissionStatsService.load_stats(ApplicationRound.find(application_round_id)) : AdmissionStatsService.load_overall_stats
      @selected_round_ids = application_round_id.present? ? [application_round_id] : ApplicationRound.opened_for_applications.pluck(:id)
    end

    # overall metrics in the hash returned by the AdmissionStatsService
    OVERALL_STATS_METRICS = %i(total_applications total_applicants total_universities total_states total_visits paid_from_earlier_rounds).freeze

    # define a bunch of methods to dig the overall metrics from the stats hash
    OVERALL_STATS_METRICS.each do |m|
      define_method m do
        stats[m]
      end
    end

    # state-wise metrics in the hash returned by the AdmissionStatsService
    STATE_STATS_METRICS = %i(paid_applications paid_applications_today payment_initiated payment_initiated_today submitted_applications submitted_applications_today conversion_percentage).freeze

    # define a bunch of methods to dig the state-wise metrics from the stats hash
    STATE_STATS_METRICS.each do |m|
      define_method(m) do |state|
        if state.is_a?(State)
          stats[:state_wise_stats][state.name.to_sym][m]
        elsif state == :non_focused
          stats[:state_wise_stats][:Others][m]
        else
          stats[m]
        end
      end
    end

    def paid_applicants_by_reference
      named_references = BatchApplicant.reference_sources - ['Other (Please Specify)']
      paid_applicants = BatchApplicant.for_round_id_in(selected_round_ids).conversion.where(reference: named_references).group(:reference).count
      paid_applicants_others_count = BatchApplicant.for_round_id_in(selected_round_ids).conversion.where.not(reference: named_references).count

      paid_applicants["Other"] = paid_applicants_others_count if paid_applicants_others_count.positive?
      paid_applicants.to_json
    end

    def paid_applications_by_location
      result = BatchApplication.joins(:college).select('colleges.state_id').where(application_round_id: selected_round_ids).payment_complete.group('colleges.state_id').count
      result.map { |state_id, count| [State.find(state_id).name, count] }.to_h.to_json
    end

    def paid_applications_by_date
      result = BatchApplication.where(application_round_id: selected_round_ids).payment_complete.joins(:payment).group_by_day('payments.paid_at').count.sort.to_h
      result.map { |k, v| [k.strftime('%b %d'), v] }.to_h.to_json
    end

    def paid_applications_by_team_size
      BatchApplication.where(application_round_id: selected_round_ids).payment_complete.group(:team_size).count.sort.to_h.to_json
    end
  end
end
