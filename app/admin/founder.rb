ActiveAdmin.register Founder do
  actions :index, :show

  permit_params :name, :avatar, :startup_id, :about, :excluded_from_leaderboard, roles: []

  collection_action :search_founder do
    render json: Founders::Select2SearchService.search_for_founder(params[:q])
  end

  menu label: 'Founders'

  filter :user_email, as: :string
  filter :name

  filter :startup_level_id, as: :select, collection: -> { Level.all.order(number: :asc) }
  filter :startup_id_null, as: :boolean, label: 'Without Startup'
  filter :roles_cont, as: :select, collection: -> { Founder.valid_roles }, label: 'Role'
  filter :created_at, label: 'Registered on'

  # Customize the index. Let's show only a small subset of the tons of fields.
  index do
    selectable_column
    column :name

    column :team_name, sortable: 'founders.startup_id' do |founder|
      if founder.startup.present?
        a href: admin_startup_path(founder.startup) do
          span do
            founder.startup.try(:name)
          end
        end
      end
    end

    actions
  end

  csv do
    column :id
    column :email
    column :name

    column :product do |founder|
      founder.startup&.name
    end

    column :roles do |founder|
      founder.roles.join ', '
    end

    column :about

    column :slack_username
  end

  show do
    attributes_table do
      row :email
      row :name

      row :roles do |founder|
        founder.roles.map do |role|
          t("models.founder.role.#{role}")
        end.join ', '
      end

      row :team_name do |founder|
        if founder.startup.present?
          a href: admin_startup_path(founder.startup) do
            span do
              founder.startup.try(:name)
            end
          end
        end
      end

      row :about
      row :slack_username
      row :slack_user_id

      row :avatar do
        if founder.avatar.attached?
          link_to(url_for(founder.avatar)) do
            image_tag(url_for(founder.avatar_variant(:thumb)))
          end
        end
      end

      row :excluded_from_leaderboard
    end

    panel 'Technical details' do
      attributes_table_for founder do
        row :id
        row :created_at
        row :updated_at
      end
    end

    active_admin_comments
  end

  action_item :impersonate, only: :show do
    link_to('Impersonate', impersonate_admin_user_path(founder.user), method: :post) if AdminUser.where(email: founder.user.email).empty?
  end

  form partial: 'admin/founders/form'
end
