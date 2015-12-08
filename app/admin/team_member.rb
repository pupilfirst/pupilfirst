ActiveAdmin.register TeamMember do
  menu parent: 'Startups'

  permit_params :startup_id, :name, :email, :avatar, roles: []

  index do
    selectable_column
    column 'Product', :startup
    column :name
    column :email

    column :roles do |user|
      user.roles.map do |role|
        t("role.#{role}")
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
          t("role.#{role}")
        end.join ', '
      end

      row :avatar do |team_member|
        image_tag team_member.avatar.thumb.url
      end
    end
  end

  form partial: 'form'
end
