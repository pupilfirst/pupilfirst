ActiveAdmin.register_page 'Vocalist Ping' do
  menu parent: 'Dashboard', label: 'Send Vocalist Ping'

  content do
    form = VocalistPingForm.new(Reform::OpenForm.new)
    render 'vocalist_ping', form: form
  end

  page_action :send_ping, method: :post do
    form = VocalistPingForm.new(Reform::OpenForm.new)

    if form.validate(params[:vocalist_ping])
      form.queue_pings(current_admin_user)
      flash[:success] = 'A job to send messages has been queued. You will receive an email with its results.'
      redirect_to admin_vocalist_ping_path
    else
      render '_vocalist_ping', form: form
      return
    end
  end
end
