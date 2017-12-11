ActiveAdmin.register Target do
  include DisableIntercom

  permit_params :faculty_id, :role, :title, :description, :resource_url, :completion_instructions, :days_to_complete,
    :slideshow_embed, :video_embed, :completed_at, :completion_comment, :rubric, :link_to_complete, :key,
    :submittability, :archived, :remote_rubric_url, :target_group_id, :target_action_type, :points_earnable,
    :timeline_event_type_id, :sort_index, :youtube_video_id, :session_at, :chore, :level_id,
    prerequisite_target_ids: [], tag_list: []

  filter :title
  filter :archived
  filter :session_at_not_null, as: :boolean, label: 'Session?'
  filter :chore, label: 'Chore?'
  filter :target_group, collection: -> { TargetGroup.all.includes(:level).order('levels.number ASC') }
  filter :level
  filter :faculty_name, as: :string
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

      row :faculty

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

  csv do
    column :id
    column :title

    column :timeline_event_type do |target|
      target&.timeline_event_type&.title
    end

    column :session do |target|
      target.session? ? 'Yes' : 'No'
    end

    column :chore do |target|
      target.chore? ? 'Yes' : 'No'
    end

    column :target_group do |target|
      target&.target_group&.name
    end

    column :level do |target|
      if target.target_group.present?
        target.target_group.level.display_name
      elsif target.level.present?
        target.level.display_name
      end
    end

    column :target_action_type
    column :points_earnable
    column :role

    column :faculty do |target|
      target&.faculty&.name
    end

    column :youtube_video_id
    column :video_embed
    column :slideshow_embed
    column :resource_url
    column :days_to_complete
    column :submittability
    column :archived do |target|
      target.archived? ? 'Yes' : 'No'
    end

    column :tags do |target|
      tags = ''
      target.tags&.each do |tag|
        tags += tag.name + ';'
      end
      tags
    end
  end

  action_item :invite_on_google_calendar, only: :show, if: proc { resource.session? } do
    link_to(
      'Invite on Google Calendar',
      invite_on_google_calendar_admin_target_url(id: params[:id]),
      method: :post, data: { confirm: 'Are you sure?' }
    )
  end

  member_action :invite_on_google_calendar, method: :post do
    target = Target.find params[:id]

    # Only the calender event needs to be created / updated manually.
    # Notifications and emails sent before and after the session are managed using periodic tasks.
    # See `lib/period_tasks.rake`.
    Targets::CreateOrUpdateCalendarEventService.new(target).execute
    flash[:success] = "Google Calendar invitation has been created / updated for founders in Level #{target.level.number} and above."
    redirect_to admin_target_path(target)
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

  form partial: 'admin/targets/form'
end
