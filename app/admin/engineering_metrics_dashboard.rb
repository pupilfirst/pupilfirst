ActiveAdmin.register_page 'Engineering Metrics Dashboard' do
  menu parent: 'Dashboard', label: 'Engineering Metrics'

  controller do
    include DisableIntercom

    def index
      @presenter = ActiveAdmin::EngineeringMetricsDashboardPresenter.new
    end
  end

  content do
    render 'engineering_metrics_dashboard'
  end
end
