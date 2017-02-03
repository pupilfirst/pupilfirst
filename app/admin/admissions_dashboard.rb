ActiveAdmin.register_page 'Admissions Dashboard' do
  menu parent: 'Admissions', label: 'Dashboard', priority: 0

  controller do
    skip_after_action :intercom_rails_auto_include

    def index
      @presenter = ActiveAdmin::AdmissionsDashboardPresenter.new(params[:round])
    end
  end

  content do
    render 'admissions_dashboard'
  end
end
