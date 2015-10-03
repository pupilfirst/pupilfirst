ActiveAdmin.register Target do
  menu parent: 'Startups'

  permit_params :startup_id, :assigner_id, :timeline_event_type_id, :role, :status, :title, :short_description,
    :resource_url

  preserve_default_filters!
  filter :startup,
    collection: Startup.batched,
    label: 'Product',
    member_label: proc { |startup| "#{startup.product_name}#{startup.name.present? ? " (#{startup.name})" : 's'}" }

  filter :role, as: :select, collection: Target.valid_roles

  before_create do |target|
    target.assigner = current_admin_user if target.assigner.blank?
  end

  index do
    selectable_column

    column :product do |target|
      startup = target.startup

      a href: admin_startup_path(startup) do
        span startup.product_name

        if startup.name.present?
          span class: 'wrap-with-paranthesis' do
            startup.name
          end
        end
      end
    end

    column :role do |target|
      t("role.#{target.role}")
    end

    column :status do |target|
      t("target.status.#{target.status}")
    end

    column :title
    column :assigner
    actions
  end

  show do
    attributes_table do
      row :product do |target|
        startup = target.startup

        a href: admin_startup_path(startup) do
          span startup.product_name

          if startup.name.present?
            span class: 'wrap-with-paranthesis' do
              startup.name
            end
          end
        end
      end

      row :role do |target|
        t("role.#{target.role}")
      end

      row :status do |target|
        t("target.status.#{target.status}")
      end

      row :title
      row :assigner
      row :timeline_event_type
      row :short_description
      row :resource_url
      row :created_at
      row :updated_at
    end
  end

  form partial: 'admin/targets/form'
end
