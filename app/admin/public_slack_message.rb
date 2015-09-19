ActiveAdmin.register PublicSlackMessage do
  menu parent: 'Users'
  actions :all, except: [:show, :new, :create, :edit, :update, :destroy]

  controller do
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
