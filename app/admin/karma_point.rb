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
    column :created_at

    actions
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
