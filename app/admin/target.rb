ActiveAdmin.register Target do
  menu parent: 'Startups'

  permit_params :startup_id, :assigner_id, :role, :status, :title, :short_description, :status, :resource_url,
    :completion_instructions, :due_date_date, :due_date_time_hour, :due_date_time_minute,
    :completed_at_date, :completed_at_time_hour, :completed_at_time_minute, :completion_comment

  preserve_default_filters!
  filter :startup,
    collection: Startup.batched,
    label: 'Product',
    member_label: proc { |startup| "#{startup.product_name}#{startup.name.present? ? " (#{startup.name})" : 's'}" }

  filter :role, as: :select, collection: Target.valid_roles
  filter :status, as: :select, collection: Target.valid_statuses

  before_create do |target|
    target.assigner = current_admin_user if target.assigner.blank?
  end

  member_action :duplicate, method: :get do
    target = Target.find(params[:id])

    redirect_to(
      new_admin_target_path(
        target: target.attributes.slice(
          'role', 'title', 'short_description', 'resource_url', 'completion_instructions', 'due_date'
        )
      )
    )
  end

  action_item :duplicate, only: :show do
    link_to 'Duplicate', duplicate_admin_target_path(id: params[:id])
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

    actions defaults: true do |target|
      link_to 'Duplicate', duplicate_admin_target_path(target)
    end
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
      row :completion_instructions
      row :due_date
      row :completed_at
      row :completion_comment
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs 'Target details' do
      f.input :startup,
        label: 'Product',
        member_label: proc { |startup| "#{startup.product_name}#{startup.name.present? ? " (#{startup.name})" : ''}" }

      f.input :status,
        as: :select,
        collection: Target.valid_statuses,
        include_blank: false,
        member_label: proc { |status| t("target.status.#{status}") }

      f.input :completed_at, as: :just_datetime_picker
      f.input :completion_comment
      f.input :role,
        as: :select,
        collection: Target.valid_roles,
        include_blank: false,
        member_label: proc { |role| t("role.#{role}") }

      f.input :title
      f.input :short_description
      f.input :resource_url
      f.input :completion_instructions
      f.input :due_date, as: :just_datetime_picker
      f.input :assigner, include_blank: f.object.persisted? ? false : 'Leave this be to assign yourself.'
    end

    f.actions
  end
end
