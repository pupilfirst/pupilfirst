module ActiveAdmin
  class AdmissionsDashboardPresenter
    attr_reader :stats

    def initialize(batch_id)
      @stats = batch_id.present? ? AdmissionStatsService.load_stats(Batch.find(batch_id)) : AdmissionStatsService.load_overall_stats
    end

    # overall metrics in the hash returned by the AdmissionStatsService
    OVERALL_STATS_METRICS = [
      :total_applications, :total_applicants, :total_universities, :total_states, :total_visits
    ].freeze

    # define a bunch of methods to dig the overall metrics from the stats hash
    OVERALL_STATS_METRICS.each do |m|
      define_method m do
        stats[m]
      end
    end

    # state-wise metrics in the hash returned by the AdmissionStatsService
    STATE_STATS_METRICS = [
      :paid_applications, :paid_applications_today, :payment_initiated, :payment_initiated_today,
      :submitted_applications, :submitted_applications_today, :conversion_percentage
    ].freeze

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
  end
end
