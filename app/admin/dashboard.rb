ActiveAdmin.register_page 'Dashboard' do
  controller do
    before_filter :initialize_intercom_client
    skip_after_action :intercom_rails_auto_include

    def initialize_intercom_client
      @intercom = IntercomClient.new
    end
  end

  menu priority: 1

  content do
    render 'dashboard'
  end
end
