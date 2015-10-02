ActiveAdmin.register Target do
  menu parent: 'Startups'

  permit_params :startup_id, :role, :status, :title, :short_description, :resource_url

  preserve_default_filters!
  filter :startup,
    collection: Startup.batched,
    label: 'Product',
    member_label: proc { |startup| "#{startup.product_name}#{startup.name.present? ? " (#{startup.name})" : 's'}" }

  filter :role, as: :select, collection: Target.valid_roles
  filter :status, as: :select, collection: Target.valid_statuses

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
      row :short_description
      row :resource_url
      row :created_at
      row :updated_at
    end
  end

  form partial: 'admin/targets/form'
end
