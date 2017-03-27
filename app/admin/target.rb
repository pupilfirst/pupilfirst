ActiveAdmin.register Target do
  include DisableIntercom

  permit_params :assigner_id, :role, :title, :description, :resource_url,
    :completion_instructions, :days_to_complete, :slideshow_embed, :video_embed, :completed_at, :completion_comment, :rubric,
    :remote_rubric_url, :target_group_id, :target_type, :points_earnable, :timeline_event_type_id, :sort_index,
    :session_at, :chore, :level_id, prerequisite_target_ids: [], tag_list: []

  filter :session_at_not_null, as: :boolean, label: 'Session?'
  filter :chore, label: 'Chore?'
  filter :target_group_program_week_batch_id_eq, label: 'Batch', as: :select, collection: proc { Batch.all }

  filter :target_group_program_week_id_eq, as: :select, label: 'Program Week', collection: proc {
    batch_id = params.dig(:q, :target_group_program_week_batch_id_eq)

    if batch_id.present?
      batch = Batch.find(batch_id)
      batch.program_weeks.order(:number)
    else
      [['Select Batch first', '']]
    end
  }

  filter :target_group, collection: proc {
    batch_id = params.dig(:q, :target_group_program_week_batch_id_eq)

    if batch_id.present?
      batch = Batch.find(batch_id)
      batch.target_groups.sorted_by_level
    else
      [['Select Batch first', '']]
    end
  }

  filter :level
  filter :assigner
  filter :role, as: :select, collection: Target.valid_roles
  filter :timeline_event_type
  filter :program_week
  filter :title
  filter :target_type, as: :select, collection: Target.valid_target_types

  filter :ransack_tagged_with,
    as: :select,
    multiple: true,
    label: 'Tags',
    collection: -> { Target.tag_counts_on(:tags).pluck(:name).sort }

  controller do
    def scoped_collection
      super.includes target_group: { program_week: :batch }
    end
  end

  index do
    selectable_column
    column :title

    column :level do |target|
      target.level.present? ? target.level : target.target_group&.level
    end

    column :target_group
    column :sort_index

    column :role do |target|
      t("role.#{target.role}")
    end

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
      row :session_at

      row :tags do |founder|
        linked_tags(founder.tags)
      end

      row :chore
      row :level

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
      row :video_embed
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
