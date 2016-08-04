ActiveAdmin.register_page 'Dashboard' do
  controller do
    before_filter :pull_intercom_data
    skip_after_action :intercom_rails_auto_include

    def pull_intercom_data
      # TODO: Add error handling for all intercom API interactions.
      initialize_intercom_client
      fetch_conversation_summary
      fetch_user_summary
      fetch_latest_conversations(5)
    end

    def initialize_intercom_client
      @intercom = Intercom::Client.new(app_id: ENV['INTERCOM_API_ID'], api_key: ENV['INTERCOM_API_KEY'])
    end

    def fetch_conversation_summary
      # TODO: Rewrite using the more general 'Conversation App Count Object' once issue with gem fixed.
      # refer: https://github.com/intercom/intercom-ruby/pull/238
      counts_by_admin = @intercom.counts.for_type(type: 'conversation', count: 'admin').conversation['admin']

      @open_conversations_count = counts_by_admin.inject(0) { |a, e| a + e['open'] }
      @closed_conversations_count = counts_by_admin.inject(0) { |a, e| a + e['closed'] }
    end

    def fetch_user_summary
      user_counts = @intercom.counts.for_type(type: 'user', count: 'segment').user['segment']

      @new_user_count = user_counts.find { |h| h.key? 'New' }['New']
      @active_user_count = user_counts.find { |h| h.key? 'Active' }['Active']
    end

    def fetch_latest_conversations(n)
      @conversations_to_display = []
      conversations = @intercom.conversations.find(open: true, display_as: 'plaintext').conversations[0..n]

      conversations.each do |conversation|
        id = conversation['id']
        user = @intercom.users.find(id: conversation['user']['id'])
        user_name = user.name || (user.email.present? ? user.email : user.pseudonym)
        body = conversation['conversation_message']['body']
        @conversations_to_display << { id: id, name: user_name, body: body }
      end

      @conversations_to_display
    end
  end

  menu priority: 1

  content do
    render 'dashboard'
  end
end
