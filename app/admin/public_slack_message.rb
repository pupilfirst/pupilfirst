ActiveAdmin.register PublicSlackMessage do
  menu parent: 'Users'
  actions :all, except: [:show, :new, :create, :edit, :update, :destroy]

  index do
    # selectable_column

    column :body do |message|
      simple_format message.body
    end

    column :author do |message|
      if message.user.present?
        link_to message.user.fullname, admin_user_path(message.user)
      else
        "@#{message.slack_username}"
      end
    end

    column :created_at

    # actions
  end
end
