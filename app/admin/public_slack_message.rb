ActiveAdmin.register PublicSlackMessage do
  menu parent: 'Users'
  actions :all, except: [:show, :new, :create, :edit, :update, :destroy]

  index do
    # selectable_column

    column(:body) { |message| simple_format message.body }

    column :author do |message|
      if message.user.present?
        link_to message.user.fullname, admin_user_path(message.user)
      else
        "@#{message.slack_username}"
      end
    end

    column(:channel) { |message| "##{message.channel}" }

    column :created_at

    # actions
  end
end
