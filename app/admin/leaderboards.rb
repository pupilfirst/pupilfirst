ActiveAdmin.register_page 'Leaderboards' do
  controller do
    skip_after_action :intercom_rails_auto_include
  end

  menu parent: 'Startups'

  controller do
    def index
      @batch = Batch.find_by(id: params[:karma_points_filter].try(:[], :batch)) || Batch.current_or_last

      @after = start_date.present? ? Date.parse(start_date) : DatesService.last_week_start_date
      @before = end_date.present? ? Date.parse(end_date) : DatesService.last_week_end_date

      @leaderboard = Startups::PerformanceService.new.leaderboard(@batch, start_date: @after, end_date: @before)
    end

    private

    def start_date
      params[:karma_points_filter].try(:[], :after)
    end

    def end_date
      params[:karma_points_filter].try(:[], :before)
    end
  end

  sidebar :filter_by_batch_and_date do
    render 'admin/leaderboards/karma_points_filter'
  end

  content do
    render 'admin/leaderboards/karma_points'
  end
end
