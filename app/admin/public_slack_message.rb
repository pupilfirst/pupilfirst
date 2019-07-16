ActiveAdmin.register PublicSlackMessage do
  menu parent: 'Founders'
  actions :index

  filter :founder_user_name, as: :string
  filter :slack_username, as: :string
  filter :channel, as: :string
  filter :created_at

  controller do
    include DisableIntercom

    def scoped_collection
      super.includes :founder
    end
  end

  index do
    column :author do |message|
      if message.founder.present?
        link_to message.founder.fullname, admin_founder_path(message.founder)
      else
        "@#{message.slack_username}"
      end
    end

    column(:channel) { |message| "##{message.channel}" }

    column(:body) do |message|
      pre class: 'max-width-pre' do
        message.reaction? ? reaction_details(message) : message.body
      end
    end

    column :created_at

    # actions
  end
end
