ActiveAdmin.register_page 'Vocalist Ping' do
  menu parent: 'Dashboard', label: 'Send Vocalist Ping (Beta!)'

  controller do
    skip_after_action :intercom_rails_auto_include

    def index
      @form = VocalistPingForm.new OpenStruct.new
    end
  end

  content do
    render 'vocalist_ping'
  end

  page_action :send_ping, method: :post do
    @form = VocalistPingForm.new OpenStruct.new
    if @form.validate(params[:vocalist_ping])
      response = @form.send_pings

      if !Rails.env.development? && response.errors?
        flash[:error] = response.error_message
      else
        flash[:success] = 'Pings send successfully!'
      end

      redirect_to admin_vocalist_ping_path
    else
      render '_vocalist_ping'
      return
    end
  end
end
