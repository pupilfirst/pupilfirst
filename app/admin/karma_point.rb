ActiveAdmin.register KarmaPoint do
  menu parent: 'Founders'

  permit_params :startup_id, :founder_id, :points, :activity_type, :created_at

  preserve_default_filters!
  filter :founder_startup_id_eq, label: 'Batched Startup', as: :select, collection: proc { Startup.batched.order(:product_name) }

  controller do
    def scoped_collection
      super.includes :founder
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

    column 'Founder' do |karma_point|
      if karma_point.founder.present?
        span do
          link_to karma_point.founder.fullname, admin_founder_path(karma_point.founder)
        end
      end
    end

    column :startup
    column :points
    column :activity_type
    column :source
    column :created_at

    actions defaults: true do |target|
      link_to 'Duplicate', duplicate_admin_karma_point_path(target)
    end
  end

  collection_action :founders_for_startup do
    @startup = Startup.find params[:startup_id]
    render 'founders_for_startup.json.erb'
  end

  form do |f|
    div id: 'karma-point-founders-for-startup-url', 'data-url' => founders_for_startup_admin_karma_points_url
    f.semantic_errors(*f.object.errors.keys)

    f.inputs 'Extra' do
      f.input :startup,
        include_blank: true,
        label: 'Product',
        member_label: proc { |startup| "#{startup.product_name}#{startup.name.present? ? " (#{startup.name})" : ''}" }

      f.input :founder,
        label: 'Founder',
        as: :select,
        collection: f.object.persisted? ? f.object.startup.founders : [],
        include_blank: 'Not linked to founder'

      f.input :points
      f.input :activity_type
      f.input :created_at, as: :datepicker
    end

    f.actions
  end
end
