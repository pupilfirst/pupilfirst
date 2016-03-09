ActiveAdmin.register TargetTemplate do
  menu parent: 'Targets'

  config.sort_order = 'days_from_start_asc'

  permit_params :days_from_start, :title, :role, :description, :completion_instructions, :resource_url, :slideshow_embed, :assigner_id

  member_action :create_target, method: :get do
    target_template = TargetTemplate.find(params[:id])

    redirect_to(
      new_admin_target_path(
        target: {
          role: target_template.role, title: target_template.title, description: target_template.description,
          resource_url: target_template.resource_url, completion_instructions: target_template.completion_instructions,
          due_date_date: target_template.due_date, due_date_time_hour: 23, due_date_time_minute: 59,
          slideshow_embed: target_template.slideshow_embed, assigner_id: target_template.assigner_id
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

  show do
    attributes_table do
      row :id
      row :days_from_start
      row :role
      row :title

      row :description do |target_template|
        target_template.description.html_safe
      end

      row :completion_instructions

      row :resource_url do |target_template|
        if target_template.resource_url.present?
          link_to target_template.resource_url
        end
      end

      row :slideshow_embed
      row :assigner
    end
  end

  form partial: 'admin/target_templates/form'
end
