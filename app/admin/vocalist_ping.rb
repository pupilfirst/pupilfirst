ActiveAdmin.register_page 'Vocalist Ping' do
  menu parent: 'Dashboard', label: 'Send Vocalist Ping (Beta!)'

  controller do
    skip_after_action :intercom_rails_auto_include

    def index
      @founders = Founder.all.map { |f| [f.fullname, f.id] }
      @startups = Startup.all.pluck(:product_name, :id)
      @channels = PublicSlackTalk.valid_channel_names
    end
  end

  content do
    render 'vocalist_ping'
  end

  page_action :send_ping, method: :post do
    @message = params[:vocalist_ping][:message]
    @selected_channel = params[:vocalist_ping][:channel]
    @selected_startups = params[:vocalist_ping][:startups].reject(&:empty?)
    @selected_founders = params[:vocalist_ping][:founders].reject(&:empty?)

    unless @selected_channel.present? || @selected_startups.present? || @selected_founders.present?
      flash[:error] = 'Please select a channel OR one or more startups OR founders!'
      render '_vocalist_ping'
      return
    end

    unless @message.present?
      flash[:error] = 'Please enter a message to be sent!'
      render '_vocalist_ping'
      return
    end

    response = if @selected_founders.present?
      PublicSlackTalk.post_message message: @message, founders: Founder.find(@selected_founders)
    elsif @selected_startups.present?
      PublicSlackTalk.post_message message: @message, founders: Founder.where(startup: @selected_startups)
    else
      PublicSlackTalk.post_message message: @message, channel: @selected_channel
    end

    if response.had_errors?
      flash[:error] = response.error_message
    else
      flash[:success] = 'Pings send successfully!'
    end
    redirect_to admin_vocalist_ping_path
  end
end
