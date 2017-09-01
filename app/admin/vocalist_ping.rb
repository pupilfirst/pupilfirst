ActiveAdmin.register_page 'Vocalist Ping' do
  controller do
    include DisableIntercom
  end

  menu parent: 'Dashboard', label: 'Send Vocalist Ping'

  content do
    form = VocalistPingForm.new(Reform::OpenForm.new)
    render 'vocalist_ping', form: form
  end

  page_action :send_ping, method: :post do
    form = VocalistPingForm.new(Reform::OpenForm.new)

    if form.validate(params[:vocalist_ping])
      response = form.send_pings

      if response.errors.any?
        flash[:error] = response.errors.values[0]
      else
        flash[:success] = 'Pings sent successfully!'
      end

      redirect_to admin_vocalist_ping_path
    else
      render '_vocalist_ping', form: form
      return
    end
  end
end
