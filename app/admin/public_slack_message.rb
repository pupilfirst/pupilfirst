ActiveAdmin.register PublicSlackMessage do
  menu parent: 'Founders'
  actions :index

  controller do
    def index
      index! do |format|
        format.txt do
          messages = collection.limit(100_000).pluck(:created_at, :channel, :slack_username, :body).each_with_object([]) do |message, messages_array|
            messages_array << "#{message[0].in_time_zone('Asia/Calcutta')} ##{message[1]} @#{message[2]}: #{message[3]}"
          end.reverse.join "\n"
          render text: messages
        end
      end
    end

    def scoped_collection
      super.includes :founder
    end
  end

  action_item :assign_karma_points, only: :index do
    link_to 'Assign Karma Points', assign_karma_points_admin_public_slack_messages_path
  end

  collection_action :assign_karma_points do
    @channel = params[:channel] || 'general'

    @date = if params[:date].present?
      Date.parse(params[:date])
    else
      Date.today
    end

    @public_slack_messages = PublicSlackMessage.where(channel: @channel, created_at: (@date.beginning_of_day..@date.end_of_day))
      .includes(:founder, :karma_point)

    @batch = params[:batch].present? ? Batch.find(params[:batch]) : nil
    @public_slack_messages = @public_slack_messages.from_batch(@batch).order('created_at ASC') if @batch.present?

    render 'assign_karma_points'
  end

  member_action :create_karma_points, method: :post do
    public_slack_message = PublicSlackMessage.find(params[:id])

    if public_slack_message.karma_point.present?
      render json: { error: :duplicate_karma_point }
      return
    end

    if public_slack_message.founder.blank?
      render json: { error: :user_not_linked }
      return
    end

    karma_point = KarmaPoint.create!(
      source: public_slack_message,
      points: params[:commit].delete('+').to_i,
      activity_type: params[:activity_type],
      founder: public_slack_message.founder
    )

    render json: {
      public_slack_message_id: public_slack_message.id,
      id: karma_point.id,
      activity_type: karma_point.activity_type,
      points: karma_point.points,
      url: admin_karma_point_url(karma_point)
    }
  end

  index download_links: [:txt, :json, :xml] do
    # selectable_column

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
