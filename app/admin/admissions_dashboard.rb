ActiveAdmin.register_page 'Admissions Dashboard' do
  menu parent: 'Dashboard'

  controller do
    before_filter :initialize_intercom_client
    skip_after_action :intercom_rails_auto_include

    def initialize_intercom_client
      @intercom = IntercomClient.new
    end
  end

  content do
    render 'admissions_dashboard'
  end
end
