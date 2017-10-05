ActiveAdmin.register Player do
  menu parent: 'Admissions', label: 'Tech-Hunt Players'

  actions :index, :show

  filter :user_email_contains
  filter :name
  filter :stage
  filter :college_name_contains
  filter :college_text

  controller do
    def scoped_collection
      super.includes :college, :user
    end
  end

  index do
    selectable_column

    column :name

    column :college do |player|
      if player.college.present?
        link_to player.college.name, admin_college_path(player.college)
      elsif player.college_text.present?
        span "#{player.college_text} "
        span admin_create_college_link(player.college_text)
      else
        content_tag :em, 'Unknown'
      end
    end

    column :stage
    column :showcase_link

    actions do |player|
      item 'Invite to Join', accept_request_admin_player_path(player), method: :post, class: 'member_link' if player.stage.zero?
    end
  end

  member_action :accept_request, method: :post do
    player = Player.find params[:id]
    user = player.user
    player.update!(stage: 1)
    user.regenerate_login_token if user.login_token.blank?
    PlayerMailer.welcome(player).deliver_later
    redirect_back(fallback_location: admin_players_path)
  end

  action_item :accept_request, only: :show, if: proc { Player.find(params[:id]).stage.zero? } do
    link_to 'Invite to Join', accept_request_admin_player_path(player), method: :post
  end
end
