ActiveAdmin.register TeamMember do
  include DisableIntercom

  menu parent: 'Startups'

  permit_params :startup_id, :name, :email, :avatar, roles: []

  filter :startup_product_name, as: :string, label: 'Product Name'
  filter :startup_name, as: :string, label: 'Startup Name'
  filter :name, as: :string
  filter :email, as: :string
  filter :roles, as: :string
  filter :created_at

  index do
    selectable_column
    column 'Product', :startup
    column :name
    column :email

    column :roles do |team_member|
      team_member.roles.map do |role|
        t("models.team_member.role.#{role}")
      end.join ', '
    end

    actions
  end

  show do
    attributes_table do
      row :id

      row 'Product' do |team_member|
        if team_member.startup.present?
          link_to team_member.startup.display_name, admin_startup_path(team_member.startup)
        end
      end

      row :name
      row :email

      row :roles do |team_member|
        team_member.roles.map do |role|
          t("models.team_member.role.#{role}")
        end.join ', '
      end

      row :avatar do |team_member|
        image_tag team_member.avatar.thumb.url if team_member.avatar.present?
      end
    end
  end

  form partial: 'form'
end
