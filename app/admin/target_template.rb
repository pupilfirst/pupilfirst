ActiveAdmin.register TargetTemplate do
  menu parent: 'Startups'

  config.sort_order = 'days_from_start_asc'

  member_action :create_target, method: :get do
    target_template = TargetTemplate.find(params[:id])

    redirect_to(
      new_admin_target_path(
        target: {
          role: target_template.role, title: target_template.title, description: target_template.description,
          resource_url: target_template.resource_url, completion_instructions: target_template.completion_instructions,
          due_date_date: target_template.due_date, due_date_time_hour: 23,
          due_date_time_minute: 59
        }
      )
    )
  end

  action_item :create_target, only: :show do
    link_to 'Create Target', create_target_admin_target_template_path(id: params[:id])
  end

  index do
    selectable_column
    column :days_from_start
    column :title
    column :role

    actions defaults: true do |target_template|
      link_to 'Create Target', create_target_admin_target_template_path(target_template)
    end
  end

  form do |f|
    f.inputs 'Target Template Details' do
      f.input :days_from_start
      f.input :title
      f.input :role, as: :select, collection: Target.valid_roles, include_blank: false
      f.input :description
      f.input :completion_instructions
      f.input :resource_url
    end

    f.actions
  end

  permit_params :days_from_start, :title, :role, :description, :completion_instructions, :resource_url
end
