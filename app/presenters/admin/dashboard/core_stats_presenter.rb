module Admin
  module Dashboard
    # Presenter for summarizing and reporting the core stats on admin dashboard.
    class CoreStatsPresenter < ApplicationPresenter
      def initialize(view_context, data)
        @data = data
        super(view_context)
      end

      def nps_report
        nps = format('%+d', @data[:nps])
        nps_count = view.pluralize(@data[:nps_count], 'score')

        "Net Promoter Score: #{nps} (from #{nps_count})"
      end

      def stats_summary(platform, metric)
        value = @data[platform][metric]
        percentage = @data[platform]["percentage_#{metric}".to_sym]
        formatted_percentage = format('%g', format('%0.1f', percentage))

        "#{platform_name(platform)}: #{value} (#{formatted_percentage}%)"
      end

      def calculation_period(metric)
        case metric
          when :dau then "Yesterday (#{1.day.ago.strftime('%B %e')})"
          when :wau then "Last Week (#{8.days.ago.strftime('%B %e')} - #{1.day.ago.strftime('%B %e')})"
          when :mau then "Last Month (#{31.days.ago.strftime('%B %d')} - #{1.day.ago.strftime('%B %e')})"
        end
      end

      def wau_trend(platform)
        @data[platform][:wau_trend].join(', ')
      end

      def platform_name(platform)
        platform.to_s.capitalize
      end

      def metrics
        %i[dau wau mau]
      end

      def platforms
        %i[slack web total]
      end
    end
  end
end
