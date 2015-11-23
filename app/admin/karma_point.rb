ActiveAdmin.register KarmaPoint do
  menu parent: 'Users'

  permit_params :user_id, :points, :activity_type, :created_at

  preserve_default_filters!
  filter :user_startup_id_eq, label: 'Startup from Batch 1', as: :select, collection: proc { Startup.where(batch: 1) }

  controller do
    def scoped_collection
      super.includes :user
    end
  end

  member_action :duplicate, method: :get do
    karma_point = KarmaPoint.find(params[:id])

    redirect_to(
      new_admin_karma_point_path(
        karma_point: { points: karma_point.points, activity_type: karma_point.activity_type, created_at: karma_point.created_at }
      )
    )
  end

  action_item :duplicate, only: :show do
    link_to 'Duplicate', duplicate_admin_karma_point_path(id: params[:id])
  end

  index do
    selectable_column

    column :user do |karma_point|
      span do
        link_to karma_point.user.fullname, karma_point.user
      end

      if karma_point.startup
        span class: 'wrap-with-paranthesis' do
          link_to karma_point.startup.product_name, karma_point.startup
        end
      end
    end

    column :points
    column :activity_type
    column :source
    column :created_at

    actions defaults: true do |target|
      link_to 'Duplicate', duplicate_admin_karma_point_path(target)
    end
  end

  form do |f|
    f.inputs 'Extra' do
      f.input(
        :user,
        collection: User.founders,
        member_label: proc { |u| "#{u.fullname}#{u.roles.present? ? " (#{founder_roles(u.roles)})" : ''} - #{u.startup.product_name}" },
        input_html: { style: 'width: calc(80% - 22px);' }
      )

      f.input :points
      f.input :activity_type
      f.input :created_at, as: :datepicker
    end

    f.actions
  end
end
