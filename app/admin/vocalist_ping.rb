ActiveAdmin.register_page 'Vocalist Ping' do
  controller do
    include DisableIntercom
  end

  menu parent: 'Dashboard', label: 'Send Vocalist Ping (Beta!)'

  content do
    form = VocalistPingForm.new(OpenStruct.new)
    render 'vocalist_ping', form: form
  end

  page_action :send_ping, method: :post do
    form = VocalistPingForm.new(OpenStruct.new)

    if form.validate(params[:vocalist_ping])
      response = form.send_pings

      if response&.errors?
        flash[:error] = response.error_message
      else
        flash[:success] = 'Pings send successfully!'
      end

      redirect_to admin_vocalist_ping_path
    else
      render '_vocalist_ping', form: form
      return
    end
  end
end
