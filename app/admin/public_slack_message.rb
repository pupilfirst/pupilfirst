ActiveAdmin.register PublicSlackMessage do
  menu parent: 'Users'
  actions :all, except: [:show, :new, :create, :edit, :update, :destroy]

  index download_links: [:txt, :xml, :json]

  controller do
    def index
      index! do |format|
        format.txt do
          messages = collection.pluck(:created_at, :channel, :slack_username, :body).each_with_object([]) do |message, messages|
            messages << "#{message[0].in_time_zone('Asia/Calcutta')} ##{message[1]} @#{message[2]}: #{message[3]}"
          end.join "\n"
          render text: messages
        end
      end
    end

    def scoped_collection
      super.includes :user
    end
  end

  index do
    # selectable_column

    column :author do |message|
      if message.user.present?
        link_to message.user.fullname, admin_user_path(message.user)
      else
        "@#{message.slack_username}"
      end
    end

    column(:channel) { |message| "##{message.channel}" }

    column(:body) do |message|
      pre class: 'max-width-pre' do
        message.body
      end
    end

    column :created_at

    # actions
  end
end
