ActiveAdmin.register_page 'Dashboard' do
  controller do
    include DisableIntercom

    def index
      @core_stats = Admin::CoreStatsService.new.stats
    end
  end

  menu priority: 1

  content do
    render 'dashboard'
  end

  # route to respond to ajax request for intercom conversations
  # page_action :intercom_conversations do
  #   @conversations = IntercomClient.new.latest_conversation_array(5)
  #   render 'intercom_conversations', layout: false
  # end
end
