ActiveAdmin.register Target do
  include DisableIntercom

  permit_params :assigner_id, :role, :title, :description, :resource_url, :completion_instructions, :days_to_complete,
    :slideshow_embed, :video_embed, :completed_at, :completion_comment, :rubric, :link_to_complete, :key,
    :submittability, :archived, :remote_rubric_url, :target_group_id, :target_action_type, :points_earnable,
    :timeline_event_type_id, :sort_index, :youtube_video_id, :session_at, :chore, :level_id,
    prerequisite_target_ids: [], tag_list: [], target_performance_criteria_attributes: %i[id performance_criterion_id rubric_good rubric_great rubric_wow base_karma_points _destroy]

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
      t("models.target.role.#{target.role}")
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
        t("models.target.role.#{target.role}")
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

      row :youtube_video_id do
        if target.youtube_video_id.present?
          span do
            code target.youtube_video_id
            span ' - '
            a(href: "https://www.youtube.com/watch?v=#{target.youtube_video_id}", target: '_blank') do
              'Open on YouTube'
            end
          end
        else
          em 'No YouTube Video ID available'
        end
      end

      row :video_embed
      row :slideshow_embed
      row :resource_url
      row :completion_instructions
      row :days_to_complete
      row :completion_comment
      row :link_to_complete
      row :submittability
      row :archived do
        div class: 'target-show__archival-status' do
          target.archived ? 'Yes' : 'No'
        end

        div class: 'target-show__archive-button' do
          span do
            if !target.archived?
              button_to(
                'Archive Target',
                archive_target_admin_target_path(target: { archived: true }),
                method: :put, data: { confirm: 'Are you sure you want to archive this target? This will wipe the pre-requisite mappings of this target if any' }
              )
            else
              button_to(
                'Unarchive Target',
                archive_target_admin_target_path(target: { archived: false }),
                method: :put, data: { confirm: 'Are you sure you want to unarchive this target?' }
              )
            end
          end
        end
      end

      row :created_at
      row :updated_at
    end
  end

  member_action :archive_target, method: :put do
    target = Target.find params[:id]
    params = permitted_params[:target]

    service = Targets::ArchivalService.new(target)
    params[:archived] == 'true' ? service.archive : service.unarchive

    message_text = params[:archived] == 'true' ? 'archived' : 'unarchived'
    flash[:success] = "Target #{message_text} successfully!"
    redirect_to action: :show
  end

  collection_action :founders_for_target do
    @founders = Startup.find(params[:startup_id]).founders
    render 'founders_for_target.json.erb'
  end

  form do |f|
    presenter = Admin::Targets::FormPresenter.new(target)
    div id: 'admin-target__edit'

    f.semantic_errors(*f.object.errors.keys)

    f.inputs name: 'Target Details' do
      f.input :role, as: :select, collection: Target.valid_roles.map { |r| [t("models.target.role.#{r}"), r] }, include_blank: false
      f.input :title
      f.input :key
      f.input :chore
      f.input :session_at, as: :string, input_html: { class: 'date-time-picker', data: { format: 'Y-m-d H:i:s O' } }
      f.input :tag_list, as: :select, collection: Target.tag_counts_on(:tags).pluck(:name), multiple: true
      f.input :level

      f.input :description, as: :hidden

      insert_tag(Arbre::HTML::Div, class: 'label-replica') do
        content_tag('abbr', '*', title: 'required')
      end

      insert_tag(Arbre::HTML::Div) { content_tag 'trix-editor', nil, class: 'input-replica', input: 'target_description' }
      insert_tag(Arbre::HTML::P, class: 'inline-errors-replica') { resource.errors[:description][0] } if resource.errors[:description].present?

      f.input :target_action_type, collection: Target.valid_target_action_types
      f.input :timeline_event_type, include_blank: 'Select default timeline event type'
      f.input :points_earnable
      f.input :prerequisite_targets, collection: presenter.valid_prerequisites
      f.input :youtube_video_id, label: 'YouTube Video ID', placeholder: 'For eg. S0PEA3R-6TU'
      f.input :video_embed
      f.input :slideshow_embed
      f.input :resource_url
      f.input :completion_instructions
      f.input :link_to_complete
      f.input :submittability, collection: Target.valid_submittability_values
      f.input :assigner, collection: Faculty.active.order(:name), include_blank: false
      f.input :target_group, collection: TargetGroup.all.sorted_by_level.includes(:level)
      f.input :sort_index
      f.input :days_to_complete
      f.input :rubric, as: :file
      f.input :remote_rubric_url
    end

    f.inputs 'Performance Criteria' do
      f.has_many :target_performance_criteria, heading: false, allow_destroy: true, new_record: 'Add PC' do |tpc|
        tpc.input :performance_criterion
        tpc.input :rubric_good
        tpc.input :rubric_great
        tpc.input :rubric_wow
        tpc.input :base_karma_points
      end
    end
    f.actions
  end
end
