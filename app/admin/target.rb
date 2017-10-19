ActiveAdmin.register Target do
  include DisableIntercom

  permit_params :assigner_id, :role, :title, :description, :resource_url,
    :completion_instructions, :days_to_complete, :slideshow_embed, :video_embed, :completed_at, :completion_comment, :rubric, :link_to_complete, :key, :submittability, :archived,
    :remote_rubric_url, :target_group_id, :target_action_type, :points_earnable, :timeline_event_type_id, :sort_index,
    :session_at, :chore, :level_id, prerequisite_target_ids: [], tag_list: []

  filter :title
  filter :archived
  filter :session_at_not_null, as: :boolean, label: 'Session?'
  filter :chore, label: 'Chore?'
  filter :target_group, collection: -> { TargetGroup.all.includes(:level).order('levels.number ASC') }
  filter :level
  filter :assigner_name, as: :string
  filter :role, as: :select, collection: -> { Target.valid_roles }
  filter :timeline_event_type_title, as: :string

  filter :ransack_tagged_with,
    as: :select,
    multiple: true,
    label: 'Tags',
    collection: -> { Target.tag_counts_on(:tags).pluck(:name).sort }

  scope :all, default: true
  scope :vanilla_targets
  scope :chores
  scope :sessions

  controller do
    def scoped_collection
      super.includes :level, target_group: :level
    end
  end

  index do
    selectable_column
    column :title

    column :level do |target|
      target.level.present? ? target.level : target.target_group&.level
    end

    column :type do |target|
      if target.chore?
        'Chore'
      elsif target.session?
        'Session'
      else
        'Target'
      end
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
      row :key
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

      row :target_group
      row :sort_index
      row :target_action_type
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
      row :link_to_complete
      row :submittability
      row :archived
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
