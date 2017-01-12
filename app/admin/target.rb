ActiveAdmin.register Target do
  include DisableIntercom

  permit_params :assignee_id, :assignee_type, :assigner_id, :role, :title, :description, :resource_url,
    :completion_instructions, :days_to_complete, :slideshow_embed, :completed_at, :completion_comment, :rubric,
    :remote_rubric_url, :review_test_embed, :target_group_id, :target_type, :points_earnable,
    :timeline_event_type_id, :sort_index, :auto_verified, prerequisite_target_ids: []

  preserve_default_filters!

  filter :target_group_program_week_batch_id_eq, label: 'Batch', as: :select, collection: proc { Batch.all }
  filter :target_group_program_week_id_eq, label: 'Program Week', as: :select, collection: proc { ProgramWeek.all }
  filter :target_group

  filter :assignee_type

  filter :assignee,
    if: proc { params.dig(:q, :assignee_type_eq).present? },
    collection: proc { Object.const_get(params.dig(:q, :assignee_type_eq)).joins(:targets).distinct }

  filter :role, as: :select, collection: Target.valid_roles

  controller do
    # def create
    #   startup = Startup.find_by id: params[:target][:startup_id]
    #
    #   @target = Target.new permitted_params[:target]
    #   @target.assignee = startup if startup.present?
    #
    #   unless @target.valid?
    #     render :new
    #     return
    #   end
    #
    #   if params.dig(:target, :role) == 'founder'
    #     # Then we're creating one of more founder targets.
    #     targets = create_multiple_founder_targets!
    #     flash[:success] = "Created #{targets.count} targets"
    #     redirect_to admin_targets_url
    #   else
    #     # Then we're just creating a single startup target.
    #     @target.save!
    #     AllTargetNotificationsJob.perform_later @target, 'new_target'
    #     flash[:success] = 'New target has been created.'
    #     redirect_to admin_target_url(@target)
    #   end
    # end
    #
    # def create_multiple_founder_targets!
    #   founder_ids = params[:target][:founder_id].reject(&:blank?)
    #   startup = Startup.find_by(id: params[:target][:startup_id])
    #
    #   # Founders can either be all (of a startup), or selected list.
    #   founders = founder_ids.include?('all') ? startup.founders : Founder.where(id: founder_ids)
    #
    #   founders.map do |founder|
    #     target = Target.new permitted_params[:target]
    #     target.assignee = founder
    #     target.save!
    #
    #     AllTargetNotificationsJob.perform_later target, 'new_target'
    #   end
    # end
  end

  index do
    selectable_column

    column :batch
    column :program_week do |target|
      program_week = target.target_group&.program_week
      if program_week.present?
        link_to(program_week.name, admin_program_week_path(program_week))
      else
        'Not Assigned'
      end
    end
    column :target_group

    column :sort_index

    column :role do |target|
      t("role.#{target.role}")
    end

    column :title

    actions
  end

  show do |target|
    if target.timeline_events.present?
      div do
        table_for target.timeline_events.includes(:timeline_event_type) do
          caption 'Linked Timeline Events'

          column 'Timeline Event' do |timeline_event|
            a href: admin_timeline_event_path(timeline_event) do
              "##{timeline_event.id} #{timeline_event.title}"
            end
          end

          column :description
          column :created_at
        end
      end
    end

    attributes_table do
      row :title
      row :timeline_event_type

      row :prerequisite_targets do
        if target.prerequisite_targets.present?
          ul do
            target.prerequisite_targets.each do |prerequisite_target|
              li do
                link_to prerequisite_target.title, admin_target_path(prerequisite_target)
              end
            end
          end
        end
      end

      # row :auto_verified
      row :assignee_type
      row :assignee
      row :batch
      row :target_group
      row :sort_index
      row :target_type
      row :points_earnable

      row :role do
        t("role.#{target.role}")
      end

      row :assigner

      row :rubric do
        if target.rubric.present?
          link_to target.rubric_identifier, target.rubric.url
        end
      end

      row :description do
        target.description.html_safe
      end

      row :slideshow_embed
      row :review_test_embed
      row :resource_url
      row :completion_instructions
      row :days_to_complete
      row :completion_comment
      row :created_at
      row :updated_at
    end
  end

  collection_action :founders_for_target do
    @founders = Startup.find(params[:startup_id]).founders
    render 'founders_for_target.json.erb'
  end

  form partial: 'admin/targets/form'
end
