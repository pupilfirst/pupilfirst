ActiveAdmin.register_page 'Leaderboards' do
  menu parent: 'Startups'

  controller do
    def index
      @batch = if params[:karma_points_filter].try(:[], :batch).present?
        Batch.find params[:karma_points_filter][:batch].to_i
      else
        Batch.current
      end

      @after = params[:karma_points_filter].try(:[], :after).present? ? Date.parse(params[:karma_points_filter][:after]) : Date.today.beginning_of_week
      @before = params[:karma_points_filter].try(:[], :before).present? ? Date.parse(params[:karma_points_filter][:before]) : Date.today
    end
  end

  sidebar :filter_by_batch_and_date do
    render 'admin/leaderboards/karma_points_filter'
  end

  content do
    render 'admin/leaderboards/karma_points'
  end
end
